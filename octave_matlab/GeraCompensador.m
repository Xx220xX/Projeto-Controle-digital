function [Gc,Gs,T] = GeraCompensador(Mp,T5)
    Gs = Motor();
    
    [Gs_z Gs_p Gs_k] = tf2zp(Gs);
    s = tf('s');
    %Compensador com cancelamento de polos e zeros
   
    zetamf = abs(log(Mp/100))/((pi^2)+(log(Mp/100))^2)^(1/2);
    wnmf = 3/(T5*zetamf);%wn
    %Polos malha fechada Smf = -(zeta*wn)+/- i(wn*sqrt(1-zeta^2))
    wdmf = (wnmf*sqrt(1-zetamf^2));
    sigmamf = zetamf*wnmf;
    smf = -sigmamf + wdmf*1j;%Raizes de Malha Fechada
    %Determinando os polos do compensador
    C1 = 1;
    for i=1:length(Gs_z)
        C1 = C1*(s-Gs_z(i));
    end
    C1=1/C1;
    %Determinando os zeros do compensador
    for i=1:length(Gs_p)
        C1 = C1*(s-Gs_p(i));
    end
    %Determinando Kc
    ppid = -2*sigmamf;
    kc = -(smf*(smf-ppid))/Gs_k;
    %Controlador PID em S
    Gc = (kc/(s*(s-ppid)))*C1;

    %FT equivalente do sistema realimentado 
    Gt = feedback(Gc*Gs);%O mesmo que Gt = feedback(Gd, 1)
    %Simula��o
    dT = 1e-2;%Tempo de amostragem da simulação
    t = 0:dT:60;%tempo de simulação
    %Entrada em degrau (amplitude 1) + onda quadrada com período de 20 [s]
    %(Amplitude .25)
    Tsq = 20;%período da onda quadrada 
    u = 1*ones(1,length(t)) - 0.25*square((2*pi*t)/Tsq); 
    y=lsim(Gt,u,t);
    figure(1)
    plot(t,u,'-g',t,y,'-r');
    title('Controle de velocidade ')
    xlabel('Tempo [s]')
    ylabel('Tensao [v]')
    T = Gt;
endfunction
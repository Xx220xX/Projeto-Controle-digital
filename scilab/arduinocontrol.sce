clc;
clear;
mtlb_close all;
function stairs(x, y)
 n=length(x);
 x_indices=int((1:2*n-1)/2)+1; // gives 1,2,2,3,3,...,2n-1,2n-1
 x_ss=x(x_indices); // the stair step graph's x values
 y_indices=int((2:2*n)/2); // gives 1,1,2,2,...,2n-2,2n-2,2n-1
 y_ss=y(y_indices)
 plot2d(x_ss,y_ss)
endfunction

function gflim(lim)
    ax=gca(),// gat the handle on the current axes
    a = ax.data_bounds
    a(3:$) = lim
    ax.data_bounds=a;
endfunction
function y=c2d(x, p)
 y = ss2tf(cls2dls(tf2ss(syslin('c',x)),p))
endfunction
function yz = dsim(G,u)
    yz = dsimul(tf2ss(Gz),u);
endfunction

s = %s;
z = %z;
pi = %pi;
// Modelo para o motor CC
function F = Motor()
    Ra=8;
    La=170e-3;
    B=3e-3;
    Jrotor=12e-3;
    Jcarga=36e-3;
    J=Jrotor+Jcarga;
    kaphif=0.5;
    G = 1/(Ra+s*La)*kaphif*1/(B+s*J);
    F = G/(1+kaphif*G);
    F = syslin('c',F);
 
    // circuito
    
endfunction


//  Verificar motor sem controlador
function vfMotor()
    G = Motor()
    endTime = 60;
    t  = 0:1e-3:endTime;
    u = (-sin(t/endTime*2*pi*3)>0) .* 1;
    u = u*0.5 + 0.8;
    y =  csim(u,t,G)
    plot(t,u);
    //    mtlb_hold on
    plot(t,y,'r')
    legend('Entrada','Velocidade angular')
endfunction


//vfMotor();
function [Gc,Gs,T] = GeraCompensador(Mp,T5)
    Gs = Motor();
    
    [Gs_z Gs_p Gs_k] = tf2zp(Gs);

    //Compensador com cancelamento de polos e zeros
    //Mp = 1;//Sobressinal em %
    //Mp=exp(-pi*(zeta/sqrt(1-zeta^2)))
    zetamf = abs(log(Mp/100))/((%pi^2)+(log(Mp/100))^2)^(1/2);
    //T5 = 0.4;//Tempo de acomodação de 5%
    //T5 = 3/(wn*zeta)
    wnmf = 3/(T5*zetamf);//wn
    //Polos malha fechada Smf = -(zeta*wn)+/- i(wn*sqrt(1-zeta^2))
    wdmf = (wnmf*sqrt(1-zetamf^2));
    sigmamf = zetamf*wnmf;
    smf = -sigmamf + wdmf*%i;//Raizes de Malha Fechada
    //Determinando os polos do compensador
    C1 = 1;
    for i=1:length(Gs_z)
        C1 = C1*(s-Gs_z(i));
    end
    C1=1/C1;
    //Determinando os zeros do compensador
    for i=1:length(Gs_p)
        C1 = C1*(s-Gs_p(i));
    end
    //Determinando Kc
    ppid = -2*sigmamf;
    kc = -(smf*(smf-ppid))/Gs_k;
    //Controlador PID em S
    Gc = (kc/(s*(s-ppid)))*C1;

    //FT equivalente do sistema realimentado 
    Gt = Gc*Gs/(1+Gc*Gs);//O mesmo que Gt = feedback(Gd, 1)
    //Simulação
    dT = 1e-1;//Tempo de amostragem da simulação
    t = 0:dT:60;//tempo de simulação
    //Entrada em degrau (amplitude 1) + onda quadrada com período de 20 [s]
    //(Amplitude .25)
    Tsq = 20;//período da onda quadrada 
    u = 1*ones(1,length(t)) - 0.25*squarewave((2*%pi*t)/Tsq); 
    y=csim(u,t,Gt);
    figure(1)
    plot(t,u,'-g',t,y,'-r');
    title('Controle de velocidade ')
    xlabel('Tempo [s]')
    ylabel('Tensao [v]')
    T = Gt;
    
endfunction

function Gz = DiscretizaCompensador(Gs,Ts)
    Gz = syslin('d',c2d(Gs,Ts));
endfunction

Ts = 40e-3
[G,Gs,T ]= GeraCompensador(0.2,1)
Gz = DiscretizaCompensador(G,Ts);

fpGs = pfss(Gs)
//disp(Gs)
//disp(fpGs)
//disp(G)
//disp(Gz)
//disp(T)
t = 0:Ts:60;
//figure

u = ones(1,length(t));
ys = csim(u,t,G);

yz = dsimul(tf2ss(Gz),u);
figure(2)
plot(t,ys,'-r',t,yz,'-b')
legend ('Gcs','Gcz');
title("Discretização do compensador, subida em rampa")
//Gz = Gz/max(abs(coeff(Gz.num)));
a = coeff(Gz.den);
b = coeff(Gz.num);
a = a($:-1:1);
b = b($:-1:1);
disp(Gz)
printf("%f ,",a');
printf("\n");
printf("%f ,",b');
printf("\n");
printf("Ts = %f\n",Ts)
disp(abs(roots(Gz.den)))

/*
disp(Gs)
printf("%f ,",coeff(Gs.num)');
printf("\n");
printf("%f ,",coeff(Gs.den)');
printf("\n");
*/

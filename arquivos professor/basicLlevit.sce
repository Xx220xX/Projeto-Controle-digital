//Controle de Posição de um sistema de levitação pneumática
clc;
clear;
s = %s; 

//Configurações básicas para a simulação
m = 0.1;
C =  0.5; 
rho = 1; 
r = 0.1; 
A = %pi*r^2; 
alfa = C*rho*A/2*m;

//Calculando a velocidade do ar para o equilibrio
g = 9.81;
vo = sqrt(g/alfa) 
//FT do movimento da bolinha
Gb = syslin('c',(2*alfa*vo)/(s^2));

//Constantes da Ventoinha
k_v = 0.02;
tal = 0.01;
//FT da ventoinha
Gv = syslin('c',k_v/(tal*s+1));

//FT equivalente da malha direta
Gs = Gv * Gb;
[Gs_z Gs_p Gs_k] = tf2zp(Gs);

//Compensador com cancelamento de polos e zeros
Mp = .01;//Sobressinal em %
//Mp=exp(-pi*(zeta/sqrt(1-zeta^2)))
zetamf = abs(log(Mp/100))/((%pi^2)+(log(Mp/100))^2)^(1/2);
T5 = 0.4;//Tempo de acomodação de 5%
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
Gt = Gc*Gv*Gb/(1+Gc*Gv*Gb);//O mesmo que Gt = feedback(Gd, 1)
//Simulação
dT = 1e-1;//Tempo de amostragem da simulação
t = 0:dT:60;//tempo de simulação
//Entrada em degrau (amplitude 1) + onda quadrada com período de 20 [s]
//(Amplitude .25)
Tsq = 20;//período da onda quadrada 
u = 1*ones(1,length(t)) - 0.25*squarewave((2*%pi*t)/Tsq); 
y=csim(u,t,Gt);
plot(t,u,'-g',t,y,'-r');
title('Controle de posição vertical')
xlabel('Tempo [s]')
ylabel('Altura [m]')

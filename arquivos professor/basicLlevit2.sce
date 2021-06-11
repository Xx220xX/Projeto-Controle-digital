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

//Compensador com cancelamento de polos e zeros
//Gc = (17884.697*s+3178.84697*s^2)/(15+s);
//Gc = Gc*(450/(s+450)) //-> Para ficar proprio
Gc = (8048113.6*s+1430481.1*s^2)/(6750+465*s+s^2);  

//FT equivalente do sistema realimentado 
Gt = Gc * Gv * Gb/(1+Gc * Gv * Gb);//O mesmo que Gt = feedback(Gd, 1)
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

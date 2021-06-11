clc
clear all
 pkg load control
 pkg load signal
[Gc,Gs,T] = GeraCompensador(2,1);
[Gz,a,b] = discretizaCompensador(Gc,10e-3);
figure(2)
step(Gz,10,Gc,10)

a
b
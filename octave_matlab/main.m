clc
clear all
try
 pkg load control
 pkg load signal
end
[Gc,Gs,T] = GeraCompensador(2,1);
[Gz,a,b] = discretizaCompensador(Gc,10e-3);
figure(2)
step(Gz,10,Gc,10)
Gc
Gz
a
b
clc;
clear;
mtlb_close all;
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
    R1 = 10e3
    C2 = La/R1
    R2 = La/Ra*1/C2
    printf("%fk %fk %fu\n",R1/1e3,R2/1e3,C2*1e6)
    
    // segundo estagio
    R1 = 1.5e3
    C2 = J/R1
    R2 = J/B*1/C2
    printf("%fk %fk %fu\n",R1/1e3,R2/1e3,C2*1e6)
endfunction

Motor()

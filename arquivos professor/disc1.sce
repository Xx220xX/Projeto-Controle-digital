clear; clc;
function y=c2d(x, p)
 y = ss2tf(cls2dls(tf2ss(syslin('c',x)),p))
endfunction
function yz = dsim(G,u)
    yz = dsimul(tf2ss(Gz),u);
endfunction
s = %s;
z = %z;
Ts = 10;
t = 0:Ts:70;
u = ones(1,length(t));
//sistema continuo

Gs = syslin('c',(66.134606 +92.808092*s +1.9695561*s^2)/(20*s+s^2))
ys = csim(u,t,Gs);
//sistema discreto
Gz = syslin('d',c2d(Gs,Ts));
yz = dsimul(tf2ss(Gz),u);
plot(t,ys,'-r',t,yz,'-b')
legend ('Gs','Gz');

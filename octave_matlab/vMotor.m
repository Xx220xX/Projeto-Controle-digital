function vMotor()
    G = Motor();
    endTime = 60;
    t  = 0:1e-3:endTime;
    u = (-sin(t/endTime*2*pi*3)>0) .* 1;
    u = u*0.5 + 0.8;
    y =  lsim(u,t,G);
    plot(t,u);
    hold on
    plot(t,y,'r')
    legend('Entrada','Velocidade angular')
end
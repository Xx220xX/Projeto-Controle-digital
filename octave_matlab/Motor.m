% Modelo para o motor CC
function F = Motor()
  s = tf('s');
    Ra=8;
    La=170e-3;
    B=3e-3;
    Jrotor=12e-3;
    Jcarga=36e-3;
    J=Jrotor+Jcarga;
    kaphif=0.5;
    G = 1/(Ra+s*La)*kaphif*1/(B+s*J);
    F = G/(1+kaphif*G);
    F = minreal(F);
endfunction
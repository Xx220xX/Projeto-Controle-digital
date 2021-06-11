function [z,p,k] = tf2zp(Tf)
 [z,k] = zero(Tf);
   p = pole(Tf);
end
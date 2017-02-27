function [I]=Vill(t,v)
l=length(t);
for i=2:l;
  I1(1)=0;
  I1(i)=I1(i-1)+trapz(t(i-1:i),v(i-1:i));
endfor
K(1)=0
for i=1:9900
  O(i)=mean(I1((i-1)*floor(l/9900)+1:min(i*floor(l/9900),l)));
  for j=1:91
    I(j+(i-1)*91)=I1(j+(i-1)*91)-O(i);
  endfor
endfor
I(length(I1))= I1(length(I1))-O(9900);
endfunction
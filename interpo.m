#%%B = A' es A transpuestas%%
#%%Tomo T, la unión y ordenado de todos los tiempos de medicion
#%%j lo pido para tomar el primer tiempo de la medición del canal j
#%%k = cantidad de canales, k+1 es la frecuencia en la que mide cada canal (frecuencia en indice de T)

function [I] = interpo(A,T,k,j)
  h=length(T);
  a=length(A);
  I = zeros(1,h);
  for i=1:length(A)
    for l = 1:k
      if ((i-1)*k+l <= j+k-1)
        I((i-1)*k+l) = ((A(2)-A(1))/(T(j+k)-T(j)))*(T(l)-T(j)) + A(1);
      else
        if(j+k-1<(i-1)*k+l<=k*a-(k-j)-1)
          I((i-1)*k+l) = ((A(i)-A(i-1))/(T(k*(i-1)+k)-T(k*(i-1))))*(T(k*(i-1)+l-1)-T(k*(i-1)))+A(i);
        else
          for r = 1:k-j+1
          I(a*k+r) = ((A(a)-A(a-1)/(T(k*(a-1)+j+k)-T(k*(a-1)+j))))*(T(k*(a-1)+j+l-1)-T(k*(a-1)+j))+A(a-1);
          endfor  
        endif
      endif  
    endfor
  endfor
endfunction
  
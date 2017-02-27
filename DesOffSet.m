function [Vo]=DesOffSet(v)
#esto solo sirve si tenes asegurado q la funcion es simetrica respecto del 0
#en el caso de usarla para otra cosa del mismo estilo, habria q tocar el valor maximo de i
#lo q hace esto es dividir tu intervalo en intervalos mas chiquitos y a cada uno los centra respecto del 0
#restandole el promedio de todos sus puntos, si la cantidad de puntos que promedia es menor a la cantidad de puntos
#que hay en por lo menos un periodo va a hacer cagadas....
l=length(v);
for i=1:9900
  O(i)=mean(v((i-1)*floor(l/9900)+1:min(i*floor(l/9900),l)));
  for j=1:91
    Vo(j+(i-1)*91)=v(j+(i-1)*91)-O(i);
  endfor
endfor
Vo(length(v))=v(length(v))-O(9900);
endfunction
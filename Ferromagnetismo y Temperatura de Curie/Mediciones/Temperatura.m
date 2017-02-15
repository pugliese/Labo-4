1;
Tabla = dlmread("TempVsRes.txt", " ");


function res = Temp(V)  % Transforma el voltaje en temperatura
  i = 1;
  res = zeros(1,length(V))-1;
  for k=1:length(V)
    while Tabla(i,2)<1000*V(k)<Tabla(i+1,2) && i<=rows(Tabla)  % La resistencia es V/1mA
      i++;                                              % y busco ensangucharla para 
    endwhile                                            % ubicar la fila
    j=1;
    if i>rows(Tabla)        % Nos pasamos de rango y el valor no está en la tabla
      disp("Voltaje fuera de rango")
    else
      while Tabla(i,j)<=1000*V(k)<=Tabla(i+1,j) || Tabla(i,j)=>1000*V(k)=>Tabla(i+1,j)   
        j++;                   % Ahora busco la columna y encuentro la posición                           
      endwhile
      if abs(Tabla(i+1,j)-1000*V(k))<abs(1000*V(k)-Tabla(i,j))
        i++;        % Elijo el valor más cercano
      endif
      if i<20
        res = 10*(i-20)-j;
      else
        res = 10*(i-20)+j;
      endif
    endif
  endfor
endfunction
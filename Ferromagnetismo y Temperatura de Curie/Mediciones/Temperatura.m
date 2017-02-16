1;
function res = Temp(V)  % Transforma el voltaje en temperatura
  Tabla = dlmread("TempVsRes.txt", " ");
  res = zeros(1,length(V))-1;
  for k=1:length(V)
    i=1;
    if V(k)==0.1
      res(k) = 0;
    else
      while i<rows(Tabla) && not(Tabla(i,2)<1000*V(k) && 1000*V(k)<Tabla(i+1,2))   % La resistencia es V/1mA
        i++;                                              % y busco ensangucharla para 
      endwhile                                            % ubicar la fila
      j=2;
      if i>rows(Tabla)        % Nos pasamos de rango y el valor no está en la tabla
        disp("Voltaje fuera de rango")
      else
        while j<columns(Tabla) && not(Tabla(i,j)<=1000*V(k) && 1000*V(k)<=Tabla(i,j+1) || (Tabla(i,j)>=1000*V(k) && 1000*V(k)>=Tabla(i,j+1)));
          j++;                   % Ahora busco la columna y encuentro la posición                           
        endwhile
        if j<columns(Tabla) && abs(Tabla(i,j+1)-1000*V(k))<abs(1000*V(k)-Tabla(i,j));
          j++;        % Elijo el valor más cercano
        endif
        if i<20
          res(k) = 10*(i-20)-(j-2);
        else
          res(k) = 10*(i-21)+(j-2);
        endif
      endif
    endif
  endfor
endfunction
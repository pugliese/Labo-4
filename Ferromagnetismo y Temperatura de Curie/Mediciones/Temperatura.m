1;

global Tabla
Tabla = dlmread("TempVsRes.txt", " ");
Tabla = vec(Tabla(:,2:columns(Tabla)));   % Transformo la tabla en un vector
Tabla = sort(Tabla);    % Ordeno aprovechando que R(T) es creciente
Tabla = [Tabla(1:200); Tabla(202:length(Tabla))];  % Saco el 100 que está 2 veces

function res = Temp(V)  % Transforma el voltaje en temperatura
  global Tabla          % V tiene que ser un vector creciente
  assert(1000*V<=Tabla(length(Tabla)) && 1000*V>=Tabla(1))
  res = 0*V;
  it = res;
  i = 1;
  s = length(Tabla);
  while i+1<s       % BUSQUEDA BINARIAA (solo es importante en la primer iteracion)
    m = floor((s+i)/2);
    if Tabla(m)<V(1)*1000   % Busco hasta ensanguchar al valor entre 
      i = m;                % dos elementos para interpolar
    else
      s = m;
    endif
  endwhile
  for k=1:length(V)
    while 1000*V(k)>Tabla(s)
      s++;
    endwhile
    res(k) = s-201+(1000*V(k)-Tabla(s-1))/(Tabla(s)-Tabla(s-1)); % Interpolo
  endfor
endfunction

    
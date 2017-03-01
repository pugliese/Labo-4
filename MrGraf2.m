function [Mr,Tr]=MrGraf2(t,H,M,f);
  L = length(H);
  N = floor(2*180*f); % Cantidad de ceros (aprox el doble de cantidad de ciclos)
  m = floor(7557/(2*f)); % Cantidad de puntos en un semi-ciclo
  inf = 1;
  sup = m+1;    % Me aseguro de enganchar bien el primer 0 en el rango
  for j=1:N
    sup = min(sup+floor(3*m/2), L);   % Avanzo un semi-ciclo entero, dandole 
    inf = min(inf+floor(m/2),sup-1);  % margen a los punteros
    while inf+1<sup
      mid = floor((inf+sup)/2);
      if H(inf)*H(mid)>0  % Tienen el mismo signo, uno sobra
        inf = mid;
      else
        sup = mid;
      endif
    endwhile
    if inf==sup && H(sup)>0
      disp("Dieron igual")
      inf--;
    else if inf==sup && H(sup)<=0
      disp("Dieron igual")
      sup++;
    endif
    endif
    if abs(H(inf))>abs(H(sup))   % Me fijo cual de los 2 est� m�s cerca del 0
      Mr(j) = M(sup)-(M(sup)-M(inf))*H(sup)/(H(sup)-H(inf));
      Tr(j) = t(sup)-(t(sup)-t(inf))*H(sup)/(H(sup)-H(inf));
    else                         % Interpolo con todo el flow
      Mr(j) = M(inf)-(M(sup)-M(inf))*H(inf)/(H(sup)-H(inf));
      Tr(j) = t(inf)-(t(sup)-t(inf))*H(inf)/(H(sup)-H(inf));
    endif
  endfor
  plot(Tr,Mr,".");
save MagRemVar Tr Mr
endfunction

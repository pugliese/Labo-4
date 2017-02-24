function [Xs, Ys] = smooth(X,Y,n=10)
  assert(length(X)==length(Y))
  N = floor(length(X)/n);
  for i=1:(N-1)
    Xs(i) = sum(X(i*n:(i+1)*n))/n;
    Ys(i) = sum(Y(i*n:(i+1)*n))/n;
  endfor
  if n*N<length(X)
    Xs(N) = sum(X(N*n:length(X)))/n;
    Ys(N) = sum(Y(N*n:length(X)))/n;
  endif
endfunction

% Es muy bueno cuando tenés razones para creer que el DeltaX es aproximadamente
% constante a lo largo de la función.

function [Xs,Ys] = smoothG(X,Y,s,n=0)    % Gaussian Smoothing
  assert(length(X)==length(Y))      % s es el "desvio estandar" representa una
  N = length(X);                    % especie de rango donde los puntos "aportan"
  
  if n==0   % El promediado se hace en todo el rango posible
    for i=1:N 
      Gx = exp(-.5*((X-X(i))/s).^2)/(s*sqrt(2*pi));  % Peso de cada punto
      Ys(i) = Gx*Y';                              % dependiendo de su distancia
    endfor
    Xs = X;
  elseif n<0   % Los n negativos implica que se filtren puntos
    M = floor(N/n);
    for i=1:(M-1)
      Xs(i) = sum(X(i*n:(i+1)*n))/n;
      Gx = exp(-.5*((X(i*n:(i+1)*n)-Xs(i))/s).^2)/(s*sqrt(2*pi)); % Peso de cada
      Ys(i) = Gx*Y(i*n:(i+1)*n)';            % punto dependiendo de su distancia
    endfor
    if n*M<N
      Xs(M) = sum(X(n*M:N))/n;
      Gx = exp(-.5*((X(n*M:N)-Xs(M))/s).^2)/(s*sqrt(2*pi));
      Ys(M) = Gx*Y(n*M:N)';      
    endif
  else % Los n positivos implican que no se filtre ningún punto
    for i=1:N
      Gx = exp(-.5*((X(max(0,i-floor(n/2)):min(N,i+ceil(n/2)))-Xs(i))/s).^2);
      Ys(i) = Gx*Y(max(0,i-floor(n/2)):min(N,i+ceil(n/2)))'/sum(Gx);   
      % Peso de cada punto dependiendo de su distancia
    endfor
    Xs = X;
  endif
endfunction

% Este smooth está bueno porqué le da más bola a las distancias en el eje x
% que el smooth común. A efectos prácticos es una convolución con la gaussiana.
% Para n<0 hace lo mismo que smooth, pero pesando cada valor distinto.
% Para n=0 hace la suma ponderada para TODOS los valores del intervalo sin 
% eliminar ningún punto.
% Para n>0 hace un punto medio entre las anteriores, promediando gaussianamente 
% pero sin alejarse más de n/2 puntos a cada lado para evitar hacer muchas
% cuentas cuando max(X)-min(X)>>s (es al pedo porque terminan aportando 0). 
% En los últimos 2 casos, los extremos se ven menos afectados que el centro. 

%%% OJO1: No usar valores de s muy grandes porque el alisado tiende a hacer 
%%% mierda la función. Con "muy grande" me refiero a s~Periodo*Amp(R)/Amp(Y)=So
%%% donde Amp(R) y Amp(Y) son las amplitudes del ruido y la señal respectivamente.
%%% En general, usar s~So/6 (lo testie a ojímetro, puede variar).
%%% Recordar que ante la duda, setear un n grande puede contrarrestar un s grande.

%%% OJO2: Como todo buen smooth, funciona mejor para funciones "pseudoperíodicas".
%%% Si no entienden que quiero decir, intenten alisar una exponencial con ruido.


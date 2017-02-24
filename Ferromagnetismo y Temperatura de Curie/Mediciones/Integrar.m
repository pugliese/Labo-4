function res = Integrar(X,Y,c=0)  % Integración Forward (de X(1) a X(N))
  assert(length(X)==length(Y))     % El punto "fijado" es el primero
  N=length(X);
  res = zeros(1,N-1);
  res(1) = c; % constante de integración, valor de la integral en X(1), es 0 por default
  for i=2:(N-1)
    res(i) = res(i-1)+(Y(i)+Y(i-1))*(X(i)-X(i-1))/2;
  endfor
endfunction


function res = IntegrarB(X,Y,c=0)  % Integración Backward (de X(N) a X(1))
  assert(length(X)==length(Y))     % El punto "fijado" es el ultimo
  N=length(X);
  res = zeros(1,N);
  res(N) = c; % constante de integración, valor de la integral en X(N)
  for i=1:(N-1)
    res(N-i) = res(N-i+1)+(Y(N-i+1)+Y(N-i))*(X(N-i+1)-X(N-i))/2;
  endfor
endfunction

function res = IntegrarC(X,Y)   % Integración centrada sin offset
  assert(length(X)==length(Y))  % Se pierden los extremos, 1 punto
  N=length(X);                  % de cada lado (último y primero)
  res = zeros(1,N-2);
  res(1) = (X(3)-X(1))*(Y(1)+4*Y(2)+Y(3))/6;  % Método de Simpson
  for i=2:(N-2)
    res(i) = res(i-1)+(X(i+2)-X(i))*(Y(i)+4*Y(i+1)+Y(i+2))/6; % Hola señor
  endfor                                                      % Thompson
endfunction

% Posta que no vale la pena usar ninguna que no sea Integrar, pero las dejo
% por las dudas. IntegrarC le pifia fulero si no hay bocha de puntos.
    
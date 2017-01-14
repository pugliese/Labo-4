1;
function res = fit(fcn,X,Y,A0)
  assert(length(X)==length(Y)) % Chequeo que las longitudes coincidan
  f = @(A) sum((Y-fcn(X,A)).^2); % Defino la función que devuelve el
% error cuadrático (como la métrica de L2) entre los Y(i) y la función
% para un dado conjunto de parámetros A
  res = fminunc(f,A0); % Busco el conjunto A que minimiza el error
endfunction
% Ajusta una funcion cualquiera a una serie de puntos (X,Y).
% La funcion fcn debe tener la forma fcn(x,A) donde x son los puntos
% y A es un vector con todos los parametros a ajustar.
% Aca A0 es un vector inicial de donde empieza a buscar.
% Aun no pude incluir los errores de X e Y, asi que los parametros
% se devuelven sin error.

function res = linfit(X,Ex,Y,Ey)
  assert(length(X)==length(Y)) % Chequeo que las longitudes coincidan
  N = length(X);
  res = zeros(1,5);
  x = sum(X)/N; % Calculo los promedios, lo cual no tiene ninguna
  y = sum(Y)/N; % interpretación, solo facilita las cuentas y 
  aux1 = sum((X-x).*X);  % comprime sumas
  res(1) = sum((Y-y).*X)/aux1;
  res(3) = y-res(1)*x;
  for i=1:N
    res(2)+=((X(i)-x)*Ex(i))^2+((Y(i)+y-2*(res(1)*X(i)+res(3)))*Ey(i))^2;
  endfor
  res(2)=sqrt(res(2))/aux1;
  res(4) = sqrt((x*res(2))^2+sum((res(1)*Ex).^2+Ey.^2)/(N^2));
  res(5) = (cov(X,Y)/(std(X)*std(Y)))^2; % La covarianza entre X e Y
% dividido el producto de los desvios estandar nos da el coeficiente de
% correlacion (creo que es el Pearson's R), cuyo cuadrado es el R-square
endfunction
% Hace un ajuste lineal de (X,Y) con m*x+b devolviendo, en orden:
% m, delta m, b, delta b, R-square
% En un futuro cercano le agregaré la funcionalidad de que también
% lo grafique y capaz una forma más linda de expresar los resultados.
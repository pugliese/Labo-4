1;
function [res,error] = fit(fcn,X,Y,A0,Ex=0,Ey=0)
  assert(length(X)==length(Y)) % Chequeo que las longitudes coincidan
  T = yes_or_no("Graficar?: ");
  f = @(A) sum((Y-fcn(X,A)).^2); % Defino la funci�n que devuelve el
% error cuadr�tico (como la m�trica de L2) entre los Y(i) y la funci�n
% para un dado conjunto de par�metros A
  k = length(A0);
  N = length(X);
  res = [fminunc(f,A0), 0]; % Busco el conjunto A que minimiza el error
  res(k+1) = corr(fcn(X,res),Y)^2;   % R-square (ver en linfit)
  if T
    plot(X,Y,"*");
    hold on;
    plot(X,fcn(X,res(1:length(res)-1)),"r");
    hold off;
  endif
  if Ex != 0 && Ey!=0
    D = zeros(k,2*N);
    inc = zeros(1,N);
    for j=1:N
      inc(j) = 1E-6;
      f1 = @(A) sum((Y-fcn(X+inc,A)).^2);
      f2 = @(A) sum((Y-fcn(X-inc,A)).^2);
      D(:,j) = (fminunc(f1,res(1:k))-fminunc(f2,res(1:k)))*5E5;
      f1 = @(A) sum((Y+inc-fcn(X,A)).^2);
      f2 = @(A) sum((Y-inc-fcn(X,A)).^2);
      D(:,N+j) = (fminunc(f1,res(1:k))-fminunc(f2,res(1:k)))*5E5;
      inc(j) = 0;
    endfor
    error = sqrt(([Ex Ey].^2)*(D.^2)');
  else
    error = zeros(1,k);
  endif      
endfunction
% Ajusta una funcion cualquiera a una serie de puntos (X,Y).
% La funcion fcn debe tener la forma fcn(x,A) donde x son los puntos
% y A es un vector con todos los parametros a ajustar.
% Aca A0 es un vector inicial de donde empieza a buscar.
% Aun no pude incluir los errores de X e Y, asi que los parametros
% se devuelven sin error.
% El �ltimo elemento del resultado ser� el R-square del ajuste (la 
% forma en que lo calculo es dudosa, pero suena coherente). El resto
% son los par�metros en el orden en que aparecen en fcn.
% OJO: La funci�n fcn debe poder tomar un vector de x como par�metro.
% Esto en general no es un problema si est�n usando funciones b�sicas
% de Octave, ya que los operadores y funciones suelen estar sobrecargados
% y, en el caso de matrices, se aplican elemento a elemento.
% Por ejemplo, sin([1,2,3]) = [sin(1),sin(2),sin(3)].


%%%%%% UN EJEMPLO %%%%%%%
% Imaginense que tienen una serie de puntos (X,Y) y quieren fittear con
% una exponencial, osea algo de la forma f(x) = a*exp(b*x)+c. Entonces 
% comienzan definiendo esa funci�n ya sea de la forma cl�sica o usando
% funciones an�nimas/in-line (que es lo que voy a hacer a continuaci�n).
  % >> ExpRara = @(X,A) A(1)*exp(A(2)*X)+A(3)
% Ac� tenemos una funci�n manipulable donde matcheamos los par�metros
% seg�n A = [a,b,c]. Como dije en OJO, es importante Octave pueda hacer 
% 'exp' de una matriz (elemento a elemento). 
% Ahora, simplemente elegimos un vector se par�metros inicial. Si tenemos
% buen ojo, podemos ahorrarle unas cuantas cuentas a Octave, pero en
% general no deber�a ser necesario.
  % >> fit(ExpRara,X,Y,[1,1,1])

%%% WE NEED TO GO DEEPER %%%
% Para hacer un ejemplo m�s real, tomemos

  % >> X = 0:0.1:10;
  % >> Y = 2*exp(X/2)+rand(1,length(X))/10;
  
% Ac� rand devuelve un vector de valores aleatorios entre 0 y 1, como
% para darle "variaci�n" a los resultados. Ahora fiteamos

  % >> fit(ExpRara,X,Y,[1,1,1])
  % ans =

  %    1.999155   0.500038   0.057407   1.000000
  
% As� que podr�amos decir que le peg� bastante bien, excepto en la
% ordenada, donde le iba a pifiar porque justo ah� estaba el rand.
% A�n as�, dado que era un randoms de valores entre 0 y 1, su valor
% promedio es justamente 0.5 (y no hay que olvidar que estaba dividido
% por 10), as� que el resultado no es sorprendente.


function res = linfit(X,Ex,Y,Ey)
  assert(length(X)==length(Y)) % Chequeo que las longitudes coincidan
  T = yes_or_no("Graficar?: ");
  N = length(X);
  res = zeros(1,5);
  x = sum(X)/N; % Calculo los promedios, lo cual no tiene ninguna
  y = sum(Y)/N; % interpretaci�n, solo facilita las cuentas y 
  aux1 = sum((X-x).*X);  % comprime sumas
  res(1) = sum((Y-y).*X)/aux1;
  res(3) = y-res(1)*x;
  res(2) = sqrt(sum(((X-x).*Ex).^2+((Y+y-2*(res(1)*X+res(3))).*Ey).^2))/aux1;
  res(4) = sqrt((x*res(2))^2+sum((res(1)*Ex).^2+Ey.^2)/(N^2));
  res(5) = corr(X,Y)^2; % La covarianza entre X e Y
% dividido el producto de los desvios estandar nos da el coeficiente de
% correlacion (creo que es el Pearson's R), cuyo cuadrado es el R-square
  if T
    errorbar(X,Y,Ex,Ey,"~>*");
    hold on;
    plot(X,res(1)*X+res(3),"b");
    hold off;
  endif
endfunction
% Hace un ajuste lineal de (X,Y) con m*x+b devolviendo, en orden:
%     m, delta m, b, delta b, R-square
% En un futuro cercano le agregar� la funcionalidad de que tambi�n
% lo grafique y capaz una forma m�s linda de expresar los resultados.


function res = IntConf(X,p=.95)
  res = zeros(1,2);
  res(1) = sum(X)/length(X);
  res(2) = std(X)*stdnormal_inv(p)/sqrt(length(X));
endfunction









%%% FUNCIONES AUXILIARES (por ahora al pedo) %%%%


function res = dp(f,i,a=1E-6)
  res = @(Ao) (f(Ao+inc(Ao,i,a))-f(Ao-inc(Ao,i,a)))/(2*a);
endfunction

function res = dp2(f,i,j,a=1E-6)
  res = dp(dp(f,i,a),j,a);
endfunction

function inc = inc(V,i,a)
  inc = zeros(1,length(V));
  inc(i) = a;
endfunction

function res = Hes(f,Ao,a=1E-6)
  res = zeros(1,length(Ao));
  for i=1:length(Ao)
    for j=i:length(Ao)
      res(i,j) = dp2(f,i,j,a)(Ao);
      res(j,i) = res(i,j);
    endfor
  endfor
endfunction
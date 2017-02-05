1;
function [res,error] = fit(fcn,X,Y,A0,Ex=0,Ey=0,dfcn=0)
  assert(length(X)==length(Y)) % Chequeo que las longitudes coincidan
  T = yes_or_no("Graficar?: ");
  f = @(A) sum((Y-fcn(X,A)).^2); % Defino la función que devuelve el
% error cuadrático (como la métrica de L2) entre los Y(i) y la función
% para un dado conjunto de parámetros A
  k = length(A0);
  N = length(X);
  [res,dist,inf,out,grad,hess]= fminunc(f,A0); % Busco el conjunto A que minimiza el error
  res = [res 0];
  A_ = inv(hess);
  res(k+1) = corr(fcn(X,res),Y)^2;   % R-square (ver en linfit)
  if Ex != 0 | Ey!=0
    B = zeros(k,2*N);
    for m=1:k
      for j=1:N
        a = res(1:k);
        a(m) = 0;
        fj = @(mu) fcn(X(j),a+[zeros(1,m-1) mu zeros(1,k-m)]);
        dfj = @(mu) dfcn(X(j),a+[zeros(1,m-1) mu zeros(1,k-m)]);
        a = gradient(fj,res(m),max(res(m)*1E-6,1E-10));
        b = gradient(dfj,res(m),max(res(m)*1E-6,1E-10));
        B(m,j)= b*(fcn(X(j),res(1:k))-Y(j))+a*dfcn(X(j),res(1:k));
        B(m,j+N) = -a;
      endfor
    endfor
    B = 2*B;
    error = sqrt(([Ex Ey].^2)*((A_*B).^2)');
    if T
      errorbar(X,Y,Ex,Ey,"~>o");
      hold on;
      plot(X,fcn(X,res(1:k)),"r");
      hold off;
    endif
  else
    error = zeros(1,k);
    if T
      plot(X,Y,"o");
      hold on;
      plot(X,fcn(X,res(1:length(res)-1)),"r");
      hold off;
    endif
  endif      
endfunction
% Ajusta una funcion cualquiera a una serie de puntos (X,Y).
% La funcion fcn debe tener la forma fcn(x,A) donde x son los puntos
% y A es un vector con todos los parametros a ajustar.
% Aca A0 es un vector inicial de donde empieza a buscar.
% Aun no pude incluir los errores de X e Y, asi que los parametros
% se devuelven sin error.
% El último elemento del resultado (res) será el R-square del ajuste 
% (la forma en que lo calculo es dudosa, pero suena coherente). El 
% resto son los parámetros en el orden en que aparecen en fcn.
% Si no se especifican errores, devuelve el parámetro "error" vacío.
% Similarmente, si quieren los errores tienen que llamar a la función
% asignando de la forma
  % >> [parametros, errores] = fit(...)
  
% OJO: La función fcn debe poder tomar un vector de x como parámetro.
% Esto en general no es un problema si están usando funciones básicas
% de Octave, ya que los operadores y funciones suelen estar sobrecargados
% y, en el caso de matrices, se aplican elemento a elemento.
% Por ejemplo, sin([1,2,3]) = [sin(1),sin(2),sin(3)].


%%%%%% UN EJEMPLO %%%%%%%
% Imaginense que tienen una serie de puntos (X,Y) y quieren fittear con
% una exponencial, osea algo de la forma f(x) = a*exp(b*x)+c. Entonces 
% comienzan definiendo esa función ya sea de la forma clásica o usando
% funciones anónimas/in-line (que es lo que voy a hacer a continuación).
  % >> ExpRara = @(X,A) A(1)*exp(A(2)*X)+A(3)
% Acá tenemos una función manipulable donde matcheamos los parámetros
% según A = [a,b,c]. Como dije en OJO, es importante Octave pueda hacer 
% 'exp' de una matriz (elemento a elemento). 
% Ahora, simplemente elegimos un vector se parámetros inicial. Si tenemos
% buen ojo, podemos ahorrarle unas cuantas cuentas a Octave, pero en
% general no debería ser necesario.
  % >> fit(ExpRara,X,Y,[1,1,1])

%%% WE NEED TO GO DEEPER %%%
% Para hacer un ejemplo más real, tomemos

  % >> X = 0:0.1:10;
  % >> Y = 2*exp(X/2)+rand(1,length(X))/10;
  
% Acá rand devuelve un vector de valores aleatorios entre 0 y 1, como
% para darle "variación" a los resultados. Ahora fiteamos

  % >> fit(ExpRara,X,Y,[1,1,1])
  % ans =

  %    1.999155   0.500038   0.057407   1.000000
  
% Así que podríamos decir que le pegó bastante bien, excepto en la
% ordenada, donde le iba a pifiar porque justo ahí estaba el rand.
% Aún así, dado que era un randoms de valores entre 0 y 1, su valor
% promedio es justamente 0.5 (y no hay que olvidar que estaba dividido
% por 10), así que el resultado no es sorprendente.





function res = linfit(X,Ex,Y,Ey)
  assert(length(X)==length(Y)) % Chequeo que las longitudes coincidan
  T = yes_or_no("Graficar?: ");
  N = length(X);
  res = zeros(1,5);
  x = sum(X)/N; % Calculo los promedios, lo cual no tiene ninguna
  y = sum(Y)/N; % interpretación, solo facilita las cuentas y 
  aux1 = sum((X-x).*X);  % comprime sumas
  res(1) = sum((Y-y).*X)/aux1;
  res(3) = y-res(1)*x;
  dmdy = (X-x)/aux1;
  dmdx = (Y+y-2*(res(1)*X+res(3)))/aux1;
  res(2) = sqrt((dmdx.^2)*(Ex'.^2)+(dmdy.^2)*(Ey'.^2));
  res(4) = sqrt((res(1)/N+x*dmdx).^2*Ex'.^2+(1/N-x*dmdy).^2*Ey'.^2);
  res(5) = corr(X,Y)^2; % La covarianza entre X e Y
% dividido el producto de los desvios estandar nos da el coeficiente de
% correlacion (creo que es el Pearson's R), cuyo cuadrado es el R-square
  if T
    errorbar(X,Y,Ex,Ey,"~>o");
    hold on;
    plot(X,res(1)*X+res(3),"r");
    hold off;
  endif
endfunction
% Hace un ajuste lineal de (X,Y) con m*x+b devolviendo, en orden:
%     m, delta m, b, delta b, R-square
% En un futuro cercano le agregaré la funcionalidad de que también
% lo grafique y capaz una forma más linda de expresar los resultados.


function res = IntConf(X,p=.95)
  res = zeros(1,2);
  res(1) = sum(X)/length(X);
  res(2) = std(X)*stdnormal_inv(p)/sqrt(length(X));
endfunction

% Intervalo de Confianza de nivel p de la variable aleatoria X.
% No hay mucho que decir, el formato es 
%  promedio, error









%%% FUNCIONES AUXILIARES (por ahora al pedo) %%%%


function res = dp(f,i=1,a=1E-6)
  res = @(Ao) (f(Ao+inc(Ao,i,a))-f(Ao-inc(Ao,i,a)))/(2*a);
endfunction

function res = dp2(f,i=1,j,a=1E-6)
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
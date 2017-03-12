1;
function [res,error] = fit(fcn,X,Y,A0,B=[],g=[],h=[],Ex=0,Ey=0,dfcn=0)
  assert(length(X)==length(Y)) % Chequeo que las longitudes coincidan
  T = yes_or_no("Graficar?: ");
  f = @(A) sum((Y-fcn(X,A)).^2); % Defino la funci�n que devuelve el
% error cuadr�tico (como la m�trica de L2) entre los Y(i) y la funci�n
% para un dado conjunto de par�metros A
  if iscolumn(X)
    X = X';
  endif
  if iscolumn(Y)
    Y = Y';
  endif
  k = length(A0);
  N = length(X);
  grad=[];hess=[];
  if length(class(g))!=length("function_handle") && length(class(h))!=length("function_handle") && (columns(B)==0 || rows(B)==0)
    [res,dist,inf,out,grad,hess]= fminunc(f,A0); % Busco el conjunto A que minimiza el error
  else
    if (columns(B)==0 || rows(B)==0)
      res = sqp(A0',f,h,g)';
    else
      res = sqp(A0',f,h,g,B(1,:),B(2,:))';
    endif
    grad = gradiente(f,res);
    hess = hessiano(f,res);
  endif
  res = [res 0];
  A_ = inv(hess);
  res(k+1) = corr(fcn(X,res),Y)^2;   % R-square (ver en linfit)
  if Ex != 0 || Ey!=0
    if class(Ex)=="double" && length(Ex)==1
      Ex = ones(1,length(X))*Ex;
    endif
    if class(Ey)=="double" && length(Ey)==1
      Ey = ones(1,length(Y))*Ey;
    endif
    if length(class(dfcn))!=length("function_handle") || class(dfcn) != "function_handle"
      dfcn = @(x,A) (fcn(x+max(x*1E-6,1E-10),A)-fcn(x-max(x*1E-6,1E-10),A))/(2*max(x*1E-6,1E-10));
    endif
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
      errorbar(X,Y,Ex,Ey,"~>.");
      hold on;
      plot(X,fcn(X,res(1:k)),"r");
      hold off;
    endif
  else
    error = zeros(1,k);
    if T
      plot(X,Y,".");
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
% El �ltimo elemento del resultado (res) ser� el R-square del ajuste 
% (la forma en que lo calculo es dudosa, pero suena coherente). El 
% resto son los par�metros en el orden en que aparecen en fcn.
% Si no se especifican errores, devuelve el par�metro "error" vac�o.
% Al especificar los errores, puede agregarse opcionalmente una funci�n
% que represente la derivada anal�tica de fcn. Si no se proporciona, se
% calcula num�ricamente (ojo con eso).
% Similarmente, si quieren los errores tienen que llamar a la funci�n
% asignando de la forma
  % >> [parametros, errores] = fit(...)
  
% OJO: La funci�n fcn (y dfcn)debe poder tomar un vector de x como par�metro.
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

%%%% ACTUALIZACION: Errores en los parámetros
% Si adem�s quisieramos los errores, deberiamos tener un par de vectores
% Ex y Ey que representen los errores en X e Y respectivamente. Entonces
% definimos otra funcion
  % >> DerivExpRara = @(X,A) A(1)*A(2)*exp(A(2)*X)
% donde tenemos la derivada anal�tica de ExpRara respecto de X. Entonces 
% llamamos a fit como 
  % >> [Param, Err] = fit(ExpRara,X,Y,[1,1,1],Ex,Ey,DerivExpRara)
% Y obtenemos como resultado los mismos par�metros de antes en Param y 
% una variable m�s Err con los errores de estos par�metros.
% Si los errores son constantes, basta con ponerlo como un n�mero y el
% programa se encarga de hacerlo vector.
%%% WARNING: En la actualización siguiente el orden de los parámetros cambia así
%%% que el ejemplo está desactualizado... enchufenle tres parámetros "[]" en el
%%% medio y ya fue.



%%% ACTUALIZACION: Ajuste con restricciones
% Lo que el pueblo pedía: ¡Restricciones! ¡Ahora su función favorita acepta
% restricciones en sus parametros! ¡Llame YA al 0800-434-Aguante-Zanella y pidala!
% Si es de los primeros 3 compradores, se lleva un tutorial (de mierda) de regalo.

% Bueno, ahora la función fit toma 3 parámetros extra h, g y B que representan los
% vectores (columna) de igualdades y desigualdades respectivamente ¿Que significa esto?
% Matematicamente, g(x) = [g1(x);..;gn(x)], h(x) = [h1(x);..;hm(x)] y B = [lb;ub]
% con lb y ub vectores (B es una matriz de 2xN con N=CantidadParametros) imponen al
% programa las condiciones  g(x)>=0 (gi(x)>=0 para 1<=i<=n)
%                           h(x)=0 (hi(x)=0 para 1<=i<=m)
%                       lb<=x<=ub  (lb(i)<=x(i)<=ub(i) para 1<=i<=N)

% Pueden ver que las condiciones claramente pueden ser MOOOY complejas, pero hay
% una limitación. Es bastante paja, pero los gradientes de gi deben ser LI entre si
% y lo mismo con los gradientes de hi. Eso a primera vista parece limitante, pero no para las
% h, esas son igualdades y ya, si tienen el mismo gradiente es porque son dos condiciones
% incompatibles (f(x) = c1 y f(x)=c2) o son la misma, en cuyo caso sos un mamerto.

% El paja es B porque si ponés una sola condición tenés que completar el resto.
% Si el ajuste tiene parametros A=[A(1),A(2),A(3),A(4)] y tu condición es A(2)<3
% el B se escribiría B = [-Inf, -Inf, -Inf, -Inf; Inf, 3, Inf, Inf, Inf] Que paja, ¿no?
% OBS: Sip, Octave tiene un infinito y es de orden Inf~2^1024~8E308
% Por lo tanto, si tienen que poner una condición, es recomendable que intenten poner
% más así aprovechan y le agregan velocidad (y capaz precisión) al programa.

%%% OJO1: Recuerden que g y h toman vectores y devuelven vectores (columna), por
%%% ejemplo g = @(x) [x(1)-0.5;x(2)-x(1)] es la condición x(1)>=0.5 y x(1)<=x(2)
%%% OJO2: En general, las funciones gi y hi deberían al menos tener derivada segunda, 
%%% pero lo ideal es que fueran C2, así que funciones como abs no son bienvenidas.
%%% OJO3: Fijense que el orden de los parámetros cambió, ahora van las restricciones
%%% antes que los errores por cuestiones de uso. Sip, ahora para hacer un ajuste 
%%% normal con error hay que poner fit(fcn,X,Y,A0,[],[],[],Ex,Ey,dfcn)
%%% Pero, ¡Hey! ¡¡dfcn sigue siendo opcional!! Abajo dejo una solucion para los
%%% pajeros. Terrible, ¿no?

function [res,error] = fitSR(fcn,X,Y,A0,Ex=0,Ey=0,dfcn=0)
  [res,error] = fit(fcn,X,Y,A0,[],[],[],Ex,Ey,dfcn); % Soy una amenaza
endfunction

% DISCLAIMER: Se ahorran los "[]" pero tienen que agregar el "SR", piensenlo...


function res = linfit(X,Ex,Y,Ey)
  assert(length(X)==length(Y)) % Chequeo que las longitudes coincidan
  if class(Ex)=="double" && length(Ex)==1
    Ex = ones(rows(X),columns(X))*Ex;
  endif
  if class(Ey)=="double" && length(Ey)==1
    Ey = ones(rows(Y),columns(Y))*Ey;
  endif
  if iscolumn(X)
    X = X';
  endif
  if iscolumn(Y)
    Y = Y';
  endif
  T = yes_or_no("Graficar?: ");
  N = length(X);
  res = zeros(1,5);
  x = sum(X)/N; % Calculo los promedios, lo cual no tiene ninguna
  y = sum(Y)/N; % interpretaci�n, solo facilita las cuentas y 
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
    if Ex==0 && Ey==0
      plot(X,Y,".")
    else
      errorbar(X,Y,Ex,Ey,"~>o");
    endif
    hold on;
    plot(X,res(1)*X+res(3),"r");
    hold off;
  endif
endfunction
% Hace un ajuste lineal de (X,Y) con m*x+b devolviendo, en orden:
%     m, delta m, b, delta b, R-square


function res = IntConf(X,p=.95)
  res = zeros(1,2);
  res(1) = sum(X)/length(X);
  res(2) = std(X)*stdnormal_inv(p)/sqrt(length(X));
endfunction

% Intervalo de Confianza de nivel p de la variable aleatoria X.
% No hay mucho que decir, el formato es 
%  promedio, error

function res = gradiente(f,x,h=max(x,1)*1E-6)
  N = length(x);
  res = zeros(1,N);
  for i=1:N
    res(i) = (f([x(1:i-1) x(i)+h(i) x(i+1:N)])-f([x(1:i-1) x(i)-h(i) x(i+1:N)]))/(2*h(i));
  endfor
endfunction

function res=hessiano(f,x,h=max(x,1)*1E-6)
  N = length(x);
  res = zeros(N);
  for i=1:N
    res(i,:) = (gradiente(f,[x(1:i-1) x(i)+h(i) x(i+1:N)],h)-gradiente(f,[x(1:i-1) x(i)-h(i) x(i+1:N)],h))/(2*h(i));
  endfor
endfunction


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
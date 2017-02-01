1;
%%% Esto es un script y se utiliza escribiendo en la GUI:
%%% run leer.m
%%% Es basicamente un programa que ejecuta linea a linea lo que está 
%%% escrito como si lo hubieran escrito ustedes mismos en la consola.

% Este script toma una tabla csv (coma-separated-values) y define
% un vector para cada columna usando el titulo de la columna.
% Por ejemplo, si tenemos el archivo "Cagon.txt" compuesto de

%   Puto, TuVieja
%   1,2
%   2,4
%   3, 6

% lo corremos escribiendo "run leer.m" y luego "Cagon.txt" (las
% comillas no son necesarias) y entonces creará las variables 
% Puto=[1,2,3] y TuVieja=[2,4,6].
% Como se ve en el ejemplo, los titulos no deben tener espacios,
% pero los espacios entre números no son problema.
% 
% Por si las moscas, la tabla se guarda en la variable Data, pero
% sin los titulos.
%%% OJO1: Si las variables ya estaban definidas, las sobreescribe.
%%% OJO2: Si las columnas no tienen la misma longitud, rellena con
% ceros, así que nada de poner columnas de distintas tablas.
%%% OJO3: Si las columnas no tienen título, explicitenlo en la
% configuración de cargado (ver más adelante)
%%% AVISO: Hay un warning de strread.m que aún no entiendo, pero
% no parecería estar jodiendo

function res=y_or_n(mens)   % ¡HE TRIPLICADO MI PRODUCTIVIDAD!
  aux = "Hola";
  while aux!= "y" && aux!="n"
    aux = input([mens " (y or n) "],"s");
  endwhile
  if aux=="y"
    res = 1;
  else
    res = 0;
  endif
endfunction

    %%%%% VERSION 1 (interactiva) %%%%%

fiiile = input("Archivo: ", "s");
if y_or_n("¿Correr predeterminado?")
  ModoDeCargado = [1,1,0];
else
  ModoDeCargado = zeros(1,3);
  ModoDeCargado(1) = y_or_n("¿Crear variables?");
  ModoDeCargado(2) = y_or_n("¿Titulos en archivo?");
  if ModoDeCargado(2)==1 & ModoDeCargado(1)==1
    ModoDeCargado(3) = y_or_n("¿Redefinir titulos?");
  endif
endif
Data = csvread(fiiile, ModoDeCargado(2),0);
if ModoDeCargado(1)
  NumeroDeColumnas=columns(Data);
  TitulosDeColumnas=textread(fiiile,"%s, ",NumeroDeColumnas);
  if 1-ModoDeCargado(2) || ModoDeCargado(3)
    printf("\nInserte los titulos de cada columna\n")
    for Indice=1:NumeroDeColumnas
      printf("%d", Indice)
      TitulosDeColumnas{Indice} = input("-esima columna ","s");
    endfor
  endif
  for Indice=1:NumeroDeColumnas
    if length(TitulosDeColumnas{Indice})!=0
      eval([TitulosDeColumnas{Indice} "= Data(:,Indice)'"])
    endif
  endfor      % No uso el ";" para que se vean las variables que creeamos
  clear TitulosDeColumnas
  clear Indice    % Elimino las variables auxiliares que cree
  clear NumeroDeColumnas
endif
clear ModoDeCargado
clear fiiile
% En este modo, se pregunta inicialmente si quiere correrse en modo 
% predeterminado. Si no, se abren más opciones para customizar la
% lectura de datos.
% A esta versión es posible agregarle la opción de exceptuar columnas
% de la versión 2, pero solo lo voy a hacer si les gusta más la v1.



    %%%%% VERSION 2 (rápida) %%%%%

fiiile = input("Archivo: ", "s");
clear ModoDeCargado;
[fiiile,ModoDeCargado,ColumnasImportantes] = strread(fiiile, "%s %s %s");
fiiile = fiiile{1};
if length(ColumnasImportantes)!=0
  ColumnasImportantes = eval(["[" ColumnasImportantes{1} "]"]);
else
  ColumnasImportantes = [];
endif
if length(ModoDeCargado)!=0
  ModoDeCargado = eval(["[" ModoDeCargado{1} "]"]);
endif
if length(ModoDeCargado)==2 && sum(ModoDeCargado!=[1,1])!=0
  ModoDeCargado = [ModoDeCargado 0];
elseif length(ModoDeCargado)==3
% Si tiene longitud 3 no puede estar mal
elseif length(ModoDeCargado)==0
  ModoDeCargado = [1,1,0];
else
  disp("ERROR: Deben suministrarse 3 booleanos\nCorriendo en modo predeterminado");
  ModoDeCargado = [1,1,0];
endif
SeCrea = @(i) (sum(i==ColumnasImportantes)>0 & 1-ModoDeCargado(1)) | (sum(i==ColumnasImportantes)==0 & ModoDeCargado(1));
Data = csvread(fiiile, ModoDeCargado(2),0);
NumeroDeColumnas=columns(Data);
TitulosDeColumnas=textread(fiiile, "%s, ",NumeroDeColumnas);
if 1-ModoDeCargado(2) || ModoDeCargado(3)
  printf("\nInserte los titulos de cada columna\n")
  for Indice=1:NumeroDeColumnas
    if SeCrea(Indice)
      printf("%d", Indice)
      TitulosDeColumnas{Indice} = input("-esima columna ","s");
    endif
  endfor
endif
for Indice=1:NumeroDeColumnas
  if length(TitulosDeColumnas{Indice})!=0 & SeCrea(Indice)
    eval([TitulosDeColumnas{Indice} "= Data(:,Indice)'"])
  endif
endfor      % No uso el ";" para que se vean las variables que creeamos
clear TitulosDeColumnas
clear Indice    % Elimino las variables auxiliares que cree
clear NumeroDeColumnas
clear ModoDeCargado
clear fiiile
% En este modo, el usuario debe indicar junto al nombre del archivo
% un vector de booleanos (1's y 0's) que responden respectivamente
% a las mismas preguntas que en el modo anterior.
% Si solo escribimos el nombre del archivo, corre en predeterminado.
% El vector no tiene que estar entre corchetes y puede no contener
% un tercer elemento si los dos primeros son distintos de "1,1", pero 
% no puede haber espacios (ver las preguntas a continuación).
  % Por ejemplo, si queremos cargar el archivo "puto.txt" sin
  % títulos y no queremos guardar las variables tenemos
  %   >> run leer.m
  %   >> Archivo: puto.txt 0,0,0
  % Cabe aclarar que el tercer "0" es innecesario, pero no dañino.
  % Si quisieramos cargar un archivo sin títulos y guardar las
  % variables tendriamos 
  %   >> run leer.m
  %   >> Archivo: puto.txt [1,0,0]
  % Nuevamente, el tercer valor y los corchetes son innecesarios.
  
% Además, puede agregarse un vector de enteros para determinar 
% las EXCEPCIONES a la primer respuesta. Si fue 1, entonces son 
% las que NO deben crearse. Si fue 0, son las que DEBEN crearse.
% Los valores se toman empezando a contar desde el 1 de izquiera 
% a derecha. Si hay repetidos o valores fuera de rango, se ignoran. 
% Si no se proporciona el vector, se asume vacío.
  

% Las preguntas (en orden de aparición) significan lo siguiente
  % - ¿Crear variables? Un "n" implica que no se crean variables para
  %   cada columna. Independientemente, la tabla se guarda en Data.
  % - ¿Títulos en archivo? Si en la tabla no hay títulos, debe ponerse
  %   "n". Si la respuesta a la primer pregunta fue "y", entonces 
  %   deberán suministrarse los títulos manualmente en el orden en que 
  %   aparecen las columnas.
  % - ¿Redefinir títulos? Esta pregunta solo debe responderse si las
  %   dos preguntas anteriores fueron "y" y permite redefinir los
  %   títulos como si no estuvieran en el archivo.


% Mejoras futuras:  - Poder cargar múltiples tablas de un mismo archivo 
%                   - Poder cambiar el nombre de Data al correrlo.
%                   - Que las variables auxiliares no corran NINGUN
%                 riesgo de eliminar variables previas.


% Idea para implementar 1:
% En el archivo, separamos las tablas por lineas en blanco. Entonces
% hacemos que el script le pegue una mirada previa para ver cuantas
% tablas hay y así sabe el tamaño de las matrices a cargar. Obviamente,
% Data deberá ahora ser un array de matrices (que lindooo) para poder
% almacenar todas las tablas.

% errorbar(x1,y1,...,fmt,ex1, ey1,...) plotea con barras de error
% Todo sobre graficos está en 271-299, con especial enfasis en 272-274
% para la función "plot". 
% Para agregar todos los detalles, ver 327-333
% Al usar xlabel,ylabel,title y legend, luego del texto es posible 
% agregar el tipo de fuente y tamaño para el texto. Por ejemplo, 
  % >> xlabel('Etiqueta del eje x','FontName','Arial','FontSize', 14);
% Genera un label Arial 14. Es una paja pero garpa.
% Luego, puede guardarse escribiendo saveas(1,NombreArchivo,formato)
% donde NombreArchivo y formato son strings y formato puede ser jpg,
% png, pdf, eps, ps o emf.
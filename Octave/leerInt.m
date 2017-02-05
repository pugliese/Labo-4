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

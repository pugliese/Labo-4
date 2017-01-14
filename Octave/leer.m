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
% Por si las moscas, la tabla se guarda en la variable Data, pero
% sin los titulos.
%%% OJO1: Si las variables ya estaban definidas, las sobreescribe.
%%% OJO2: Si las columnas no tienen la misma longitud, rellena con
% ceros, así que nada de poner columnas de distintas tablas.
%%% OJO3: Si las columnas no tienen título, se pierde la primera
% fila y las variables no pueden crearse. Si solo una no tiene
% título, hay tanto bardo que paja explicar.
%%% AVISO: Hay un warning de strread.m que aún no entiendo, pero
% no parecería estar jodiendo

file = input("Archivo: ", "s");
Data = csvread(file,1,0);
NumeroDeColumnas=columns(Data);  % Los nombres de mierda son para evitar 
TitulosDeColumnas=textread(file,"%s , ",NumeroDeColumnas);%sobreescribir  
for Indice=1:NumeroDeColumnas    % variables que pudieran tener de antes
  eval([TitulosDeColumnas{Indice} "= Data(:,Indice)'"])
endfor      % No uso el ";" para que se vean las variables que creeamos
clear TitulosDeColumnas
clear Indice    % Elimino las variables auxiliares que cree
clear NumeroDeColumnas

% Mejoras futuras:  - Poder cargar múltiples tablas de un mismo archivo 
%                   - Que no sea necesario que cada columna tenga titulo,
%                 por ejemplo, dando un vector de titulos a la hora de 
%                 correr el script para que sean las nuevas variables.
%                   - Poder cambiar el nombre de Data al correrlo.
%                   - Opción para que no cree automáticamente variables.
%                   - Que las variables auxiliares no corran NINGUN
%                 riesgo de eliminar variables previas.

% Idea para implementar 2 y 4:
% Que el script lea la primera fila y se fije si efectivamente son
% títulos. Si no lo son, que pida nombres como un array de strings.
% La i-esima posición del array será el nombre de la i-esima columna
% y, si es el string vacío "", esa variable no se creará (largando un
% error). Si el array es vacío, no crea las variables.
% Si la primer fila era de títulos, procede de la forma habitual.

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
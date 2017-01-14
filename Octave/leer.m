1;
%%% Esto es un script y se utiliza escribiendo en la GUI:
%%% run leer.m
%%% Es basicamente un programa que ejecuta linea a linea lo que est� 
%%% escrito como si lo hubieran escrito ustedes mismos en la consola.

% Este script toma una tabla csv (coma-separated-values) y define
% un vector para cada columna usando el titulo de la columna.
% Por ejemplo, si tenemos el archivo "Cagon.txt" compuesto de

%   Puto, TuVieja
%   1,2
%   2,4
%   3, 6

% lo corremos escribiendo "run leer.m" y luego "Cagon.txt" (las
% comillas no son necesarias) y entonces crear� las variables 
% Puto=[1,2,3] y TuVieja=[2,4,6].
% Como se ve en el ejemplo, los titulos no deben tener espacios,
% pero los espacios entre n�meros no son problema.
% Por si las moscas, la tabla se guarda en la variable Data, pero
% sin los titulos.
%%% OJO1: Si las variables ya estaban definidas, las sobreescribe.
%%% OJO2: Si las columnas no tienen la misma longitud, rellena con
% ceros, as� que nada de poner columnas de distintas tablas.
%%% OJO3: Si las columnas no tienen t�tulo, se pierde la primera
% fila y las variables no pueden crearse. Si solo una no tiene
% t�tulo, hay tanto bardo que paja explicar.
%%% AVISO: Hay un warning de strread.m que a�n no entiendo, pero
% no parecer�a estar jodiendo

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

% Mejoras futuras:  - Poder cargar m�ltiples tablas de un mismo archivo 
%                   - Que no sea necesario que cada columna tenga titulo,
%                 por ejemplo, dando un vector de titulos a la hora de 
%                 correr el script para que sean las nuevas variables.
%                   - Poder cambiar el nombre de Data al correrlo.
%                   - Opci�n para que no cree autom�ticamente variables.
%                   - Que las variables auxiliares no corran NINGUN
%                 riesgo de eliminar variables previas.

% Idea para implementar 2 y 4:
% Que el script lea la primera fila y se fije si efectivamente son
% t�tulos. Si no lo son, que pida nombres como un array de strings.
% La i-esima posici�n del array ser� el nombre de la i-esima columna
% y, si es el string vac�o "", esa variable no se crear� (largando un
% error). Si el array es vac�o, no crea las variables.
% Si la primer fila era de t�tulos, procede de la forma habitual.

% Idea para implementar 1:
% En el archivo, separamos las tablas por lineas en blanco. Entonces
% hacemos que el script le pegue una mirada previa para ver cuantas
% tablas hay y as� sabe el tama�o de las matrices a cargar. Obviamente,
% Data deber� ahora ser un array de matrices (que lindooo) para poder
% almacenar todas las tablas.

% errorbar(x1,y1,...,fmt,ex1, ey1,...) plotea con barras de error
% Todo sobre graficos est� en 271-299, con especial enfasis en 272-274
% para la funci�n "plot". 
% Para agregar todos los detalles, ver 327-333
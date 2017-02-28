function Prueba=Pru(x)
l=length(x(:,1));

for k=1:l
load(sprintf(x(k,:)));

#aca abre los programas q va a usar q estan aparte
open smoothing.m;
open temperatura.m;
open Fitting.m;
open Integrar.m;

#aca los ejecuta para q no tire error (es que es medio tontito octave)
smoothing;
Temperatura;
Fitting;
Integrar;

#esto crea una carpeta en la cual va a guardar todos los datos del ciclo k
#(parent,dir) crea la carpeta "dir" en la carpeta "parent" 
#si no pones parent, la crea en la carpeta en la carpeta actual
mkdir(strcat('medicion-',sprintf(x(k,:)))); 

#defino variables de forma q los otros programas las puedan usar
t=time';
h=length(t);
[a,b]=smoothG(t,DesOffSet(data(:,1)'),0.001,25);
H=(400/(5*8)).*b;
clear a;
clear b;
Bint=(1/(4*pi*4*1600)).*(1/(16.2*26.7)).*DesOffSet(data(:,2))';
[a,b]=smoothG(t,data(:,3)',0.001,100);
clear a;
T=Temp(b);

#si el archivo tiene los datos del voltaje que entra al integrador, los centra y los integra.
K=length(data(1,:))
if K = 4
  Vint1=DesOffSet(data(:,4)');
  Bnum=(-1/(4*pi*4*1600)).*Vill(t,Vint1);
  clear Vint1;
else
  Vint=0
endif
clear data

#me fijo en los primeros mil puntos del vector y asumo q no crece despues mas de un 20% para establecer
#los limites que van a tener los graficos de histeresis
xmax=max(H(1:1000))*1.2;
xmin=min(H(1:1000))*1.2;
ymax=max(Bint(1:1000))*1.2;
ymin=min(Bint(1:1000))*1.2;


#esta parte grafica
if K=4
   for i=1:18
    X=H((i-1)*10*floor(h/180)+1:(i-1)*10*floor(h/180)+floor(h/360)+1);
    Y1=Bint((i-1)*10*floor(h/180)+1:(i-1)*10*floor(h/180)+floor(h/360)+1);
    Y2=Bnum((i-1)*10*floor(h/180)+1:(i-1)*10*floor(h/180)+floor(h/360)+1);
    hold on
    xlimits = xlim([xmin,xmax]);
    ylimits = ylim([ymin,ymax]);
    plot(X,Y1);
    plot(X,Y2);
    legend(strcat('Temperatura entre ', T((i-1)*10*floor(h/180)+1),'°C y ',T((i-1)*10*floor(h/180)+floor(h/360)+1),'°C'));
    saveas(gcf,strcat('medicion-',sprintf(x(k,:)),'\',sprintf(x(k,:)),'-Figure',num2str(i),'.jpg'))
    close all
  endfor
else  
   for i=1:18
    X=H((i-1)*10*floor(h/180)+1:(i-1)*10*floor(h/180)+floor(h/360)+1);
    Y=Bint((i-1)*10*floor(h/180)+1:(i-1)*10*floor(h/180)+floor(h/360)+1);
    xlimits = xlim([xmin,xmax]);
    ylimits = ylim([ymin,ymax]);
    I=plot(X,Y);
    legend(strcat('Temperatura entre ', T((i-1)*10*floor(h/180)+1),'°C y ',T((i-1)*10*floor(h/180)+floor(h/360)+1),'°C'));
    saveas(gcf,strcat('medicion-',sprintf(x(k,:)),'\',sprintf(x(k,:)),'-Figure',num2str(i),'.jpg'))
  endfor
endif
clear X
clear Y1
clear Y2

#esto va a fijarse en el nombre del archivo cual es la frecuencia tomando los primeros numeros que aparecen
f=str2num(strtrunc(sprintf(x(k,:)),findstr(sprintf(x(k,:)),"H")-1));

# findstr(s,t) te dice en que lugares del string s esta t (un string lo toma como un vector)
# strtrunc(s,n) te devuelve un string que tiene las primeras n simbolos del string s
# str2num te convierte un string de numeros a numeros, si no hiciera esto, por ejemplo,
#   tiraria error por que el 99 es un string y por lo tanto es un vector de 1x2, cuando espera un numero (1x1)

#Esta parte va a hacer el grafico de magnetizacion remanente
MrGraf2(T,H,Bint,f);
saveas(gcf,strcat('medicion-',sprintf(x(k,:)),'\MagRemInt-',sprintf(x(k,:)),'.jpg'));
load MagRemVar
save ((strcat('medicion-',sprintf(x(k,:)),'\MagRemVarInt-',sprintf(x(k,:)))),"Mr","Tr")
clear Tr
clear Mr

MrGraf2(T,H,Bnum,f);
saveas(gcf,strcat('medicion-',sprintf(x(k,:)),'\MagRemNum-',sprintf(x(k,:)),'.jpg'));
load MagRemVar
save ((strcat('medicion-',sprintf(x(k,:)),'\MagRemVarNum-',sprintf(x(k,:)))),"Mr","Tr")
clear Tr
clear Mr
#Guarda los graficos y los datos
#separados entre los q vienen de la integracion por circuito y la integracion numerica


save ((strcat('medicion-',sprintf(x(k,:)),'\datos-',sprintf(x(k,:)))),"t","H","Bint","Bnum","T");
#Guarda las variables

clear t
clear xmax
clear xmin
clear ymax
clear ymin
clear Vent
clear Vsal
clear T
#voy limpiando las variables que ya no voy a usa para q no ocupen espacio al pedo


#esto lo va a hacer dos veces, una para la integración por circuito y otro para la integración numérica
load (strcat('medicion-',sprintf(x(k,:)),'\MagRemVarInt-',sprintf(x(k,:))));
j=1;
i=1;
while i<f*90
if Mr(length(Mr)-i+1)>0
  p(j)=Mr(length(Mr)-i+1);
  j++;
  i++;
else
  i++;
endif
endwhile

n=1;
m=1;
while Tr(n)<-25
  if Mr(n)>0
    TrA(m)=Tr(n);
    MrA(m)=Mr(n);
    m++;
    n++;
  else
    n++;
  endif
endwhile
[a,MrAs]=smoothG(TrA,MrA,0.1,10);
TrA=TrA'
MrA=MrA'
MrAs=MrAs'
save ((strcat('medicion-',sprintf(x(k,:)),'\MagRemVarIntPos-',sprintf(x(k,:)))),"TrA","MrA","MrAs");

clear a
clear MrA
clear MrAs
clear Tr
clear Mr
clear TrA

load (strcat('medicion-',sprintf(x(k,:)),'\MagRemVarNum-',sprintf(x(k,:))));
#esto es un archivo que se genera adentro de la funcion MrGraf2
j=1;
i=1;
while i<f*90
if Mr(length(Mr)-i+1)>0
  p(j)=Mr(length(Mr)-i+1);
  j++;
  i++;
else
  i++;
endif
endwhile

n=1;
m=1;
while Tr(n)<-25
  if Mr(n)>0
    TrA(m)=Tr(n);
    MrA(m)=Mr(n);
    m++;
    n++;
  else
    n++;
  endif
endwhile
[a,MrAs]=smoothG(TrA,MrA,0.1,10);
TrA=TrA'
MrA=MrA'
MrAs=MrAs'
save ((strcat('medicion-',sprintf(x(k,:)),'\MagRemVarNumPos-',sprintf(x(k,:)))),"TrA","MrA","MrAs");

clear all
endfor
endfunction



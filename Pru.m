function Prueba=Pru(x)
l=length(x(:,1));

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

for k=1:l
load(sprintf(x(k,:)));

#esto crea una carpeta en la cual va a guardar todos los datos del ciclo k
#(parent,dir) crea la carpeta "dir" en la carpeta "parent" 
#si no pones parent, la crea en la carpeta en la carpeta actual
mkdir(strcat('medicion-',sprintf(x(k,:)))); 

#defino variables de forma q los otros programas las puedan usar
t=time';
h=length(t);
#Vent=smoothG(t,data(:,1)',0.001,25)(:,2)
#Vsal=smoothG(t,(data(:,2)-mean(data(:,2)))',0.001,100)(:,2);

#T=Temp(smooth(t,data(:,3)',0.001,100)(:,2));

#si el archivo tiene los datos del voltaje que entra al integrador, los centra, los smoothea, y los integra
if length data(1,:)=4
  Vint1=smoothG(t,(data(:,4)-mean(data(:,4)))',0.001,100)(:,2);
  Vint2=IntegrarC(t,Vint1);
  clear Vint1;
  Vint=[Vint2(1),Vint2,Vint2(length(Vint2))];
  clear Vint2;
else
  Vint=0
endif
clear data

#me fijo en los primeros mil puntos del vector y asumo q no crece despues mas de un 20% para establecer
#los limites que van a tener los graficos de histeresis
xmax=max(Vent(1:1000))*1.2;
xmin=min(Vent(1:1000))*1.2;
ymax=max(Vsal(1:1000))*1.2;
ymin=min(Vsal(1:1000))*1.2;



#esta parte grafica
   for i=1:18
    X=Vent((i-1)*10*floor(h/180)+1:(i-1)*10*floor(h/180)+floor(h/360)+1);
    Y=Vsal((i-1)*10*floor(h/180)+1:(i-1)*10*floor(h/180)+floor(h/360)+1);
    I=plot(X,Y);
    xlimits = xlim([xmin,xmax]);
    ylimits = ylim([ymin,ymax]);
    legend(strcat('Temperatura entre ', T((i-1)*10*floor(h/180)+1),'°C y ',T((i-1)*10*floor(h/180)+floor(h/360)+1),'°C'));
    saveas(gcf,strcat('medicion-',sprintf(x(k,:)),'\',sprintf(x(k,:)),'-Figure',num2str(i),'.jpg'))
  endfor
clear X
clear Y


#esto va a fijarse en el nombre del archivo cual es la frecuencia tomando los primeros numeros que aparecen
f=str2num(strtrunc(sprintf(x(k,:)),findstr(sprintf(x(k,:)),"H")-1));

# findstr(s,t) te dice en que lugares del string s esta t (un string lo toma como un vector)
# strtrunc(s,n) te devuelve un string que tiene las primeras n simbolos del string s
# str2num te convierte un string de numeros a numeros, si no hiciera esto, por ejemplo,
#   tiraria error por que el 99 es un string y por lo tanto es un vector de 1x2, cuando espera un numero (1x1)

#Esta parte va a hacer el grafico de magnetizacion remanente
MrGraf2(T,Vent,Vsal,f);
saveas(gcf,strcat('medicion-',sprintf(x(k,:)),'\MagRem-',sprintf(x(k,:)),'.jpg'));
#Guarda el grafico


save ((strcat('medicion-',sprintf(x(k,:)),'\datos-',sprintf(x(k,:)))),"t","Vent","Vsal","T");
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

load MagRemVar
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
os=mean(p);

#opcion 1 quitarle el offset y ajustar
#for i=1:length(Mr)
#  if Mr(i)<0
#    Mr0(i)=Mr(i)+os;
#  else
#    Mr0(i)=Mr(i)-os;
#  endif
#endfor

#clear Mr

#opcion 2 (yo uso esta ahora) ajustar usando el offset como parametro
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
clear Tr
clear Mr

MdT=@(x,A) A(1)*((A(2)-x).^(A(3)))+ A(4);

fit(MdT,TrA,MrA,[1,-17,0.4,os]);

saveas(gcf,strcat('medicion-',sprintf(x(k,:)),'\Ajuste-',sprintf(x(k,:)),'.jpg'));
#save ((strcat('C:\Users\Gonzalo\Desktop\pruebas\medicion-',sprintf(x(k,:)),'\Ajuste-',sprintf(x(k,:)))),"A");

clear Mr0
clear Tr


endfor
endfunction



function Prueba=Pru(x)
l=length(x(:,1));

for k=1:l
load(sprintf(x(k,:)));

#esto crea una carpeta en la cual va a guardar todos los datos del ciclo k
mkdir('C:\Users\Gonzalo\Desktop\pruebas',strcat('medicion-',sprintf(x(k,:)))); 
#ata k

t=time;
Vent=data(:,1);
Vsal=data(:,2)-mean(data(:,2));

#me fijo en los primeros mil puntos del vector y asumo q no crese despues mas de un 20% para establecer
#los limites que van a tener los graficos de histeresis
xmax=max(Vent(1:1000))*1.2;
xmin=min(Vent(1:1000))*1.2;
ymax=max(Vsal(1:1000))*1.2;
ymin=min(Vsal(1:1000))*1.2;

#esta parte grafica
   for i=1:18
    X=Vent((i-1)*10*7557+1:(i-1)*10*7557+3779);
    Y=Vsal((i-1)*10*7557+1:(i-1)*10*7557+3779);
    I=plot(X,Y);
    xlimits = xlim ([xmin,xmax])
    ylimits = ylim ([ymin,ymax]);
    saveas(gcf,strcat('C:\Users\Gonzalo\Desktop\pruebas\medicion-',sprintf(x(k,:)),'\',sprintf(x(k,:)),'-Figure',num2str(i),'.jpg'))
  endfor
#hasta aca

T=Temp(data(:,3));

#Esta parte va a hacer el grafico de magnetizacion remanente
MrGraf(T,Vent,Vsal,0.001);
saveas(gcf,strcat('C:\Users\Gonzalo\Desktop\pruebas\medicion-',sprintf(x(k,:)),'\MagRem-',sprintf(x(k,:)),'.jpg'));
#Guarda el grafico

save ((strcat('C:\Users\Gonzalo\Desktop\pruebas\medicion-',sprintf(x(k,:)),'\datos-',sprintf(x(k,:)))),"t","Vent","Vsal","T");
#Guarda las variables

clear t
clear Vent
clear Vsal
clear T
clear xmax
clear xmin
clear ymax
clear ymin

endfor
endfunction



disp('NI USB-6210')
disp('MANUAL: ')


% Para saber que aparatos hay conectados
daq.getDevices


ai = daq.createSession('ni');%inicializo la conexion (uso DevX sacada de las lineas anteriores)
ai.addAnalogInputChannel('Dev2', 1:4, 'Voltage') % Defino los canales con los que voy a medir
ai.Rate = 5005;%configuro rate
ai.DurationInSeconds = 180;%duracion en segundos
ai.Channels(1).Range = [-10, 10];
ai.Channels(2).Range = [-10 10];  % Seteo los rangos de los canales
ai.Channels(3).Range = [-0.2 0.2];
ai.Channels(4).Range = [-5 5];
%ai.addlistener('DataAvailable',@parar);

[data, time] = ai.startForeground;%mando un trigger, arranco la medicion
plot(time,data)
%startBackground(ai);
%pause(duracion+0.2)%espero un poquito mas que lo que dura la medicion
%wait(ai, duracion+0.2);%alternativa para esperar un poco
%[data time] = getdata(ai);%le pido los datos

figure(1)
plot(time,data)
%plot(data(:,1),data(:,2))
save 330Hzv2.mat time data
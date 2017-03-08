%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Este script es para usar la unidad de switcheo Agilent34970A  %
% a trav?s del puerto GPIB, para -por ejemplo- levantar las 5   %
% lecturas de las termocuplas del experimento de difusividad    %
% t?rmica. Dada la din?mica del experimento se puede aproximar  % 
% la serie de 5 medidas como una medida simult?nea de las 5.    %
% El programa le ordena al instrumento que haga un ?nico barrido%
% de las N medidas, y luego el matlab hace un loop para repetir %
% ese barrido las veces que haga falta.                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%MANUAL Agilent 34980A:
%http://www.keysight.com/upload/cmc_upload/All/34980-90001_Ed3.pdf?&cc=AR&lc=eng


%si esta conectado con puerto RS-232
% mux= serial('COM1');
% %tambien funciona abriendo sesi?n Visa:
% %s=visa('agilent','ASRL1::INSTR');
% %set(s,'terminator','LF');

%si esta conectado con puerto GPIB
if ~exist('mux')
    mux = visa('ni','GPIB0::9::INSTR');  % multi switch
    fopen(mux)
end
ScanInterval = 1;% ? Delay (in secs) between scans
numberScans = 3;% ? Number of scan sweeps to measure 
channelDelay = 0.2;% ? Delay (in secs) between relay closure and measurement
scanList= '(@102,103,104,105)';%List of channels to scan in each scan

%set the channel list to scan
str=sprintf('ROUTE:SCAN %s',scanList);
fprintf(mux,str);

%query number of channels to scan
j=query(mux,'ROUTE:SCAN:SIZE?');
ncanales=str2double(j);

fprintf(mux,'FORMAT:READING:CHAN ON');%" ? Return channel number with each reading
fprintf(mux,'FORMAT:READING:TIME ON');%"? Return time stamp with each reading
fprintf(mux,'FORMAT:READING:TIME:TYPE REL');% Return time stamp im seconds since scanstart
%fprintf(mux,'FORMAT:READING:TIME:TYPE ABS');%"? Return time stamp absolute



%? Set the delay (in seconds) between relay closure and measurement
str=sprintf('ROUT:CHAN:DELAY %2.1f , %s',channelDelay,scanList);
fprintf(mux,str);

% ? Number of scan sweeps to measure 
str=sprintf('TRIG:COUNT %d',numberScans);%
fprintf(mux,str);

%??
fprintf(mux,'TRIG:SOUR TIMER');

% Delay (in secs) between scans
str=sprintf('TRIG:TIMER %1.1f',ScanInterval);
fprintf(mux,str);


%START OF ONE SCAN LOOP

%start scan
j=query(mux,'INIT;:SYSTEM:TIME:SCAN?');

%wait to the end of the scan 
pause(numberScans*(channelDelay+0.1+ScanInterval));
%pause(2);
strNdata=query(mux,'DATA:POINTS?');
Ndata=str2double(strNdata);
while(Ndata<4*numberScans)
%query number of datapoints per scan
pause(1)
strNdata=query(mux,'DATA:POINTS?');
Ndata=str2double(strNdata);
end

%query the values of all the scanned channels
DATA=nan(Ndata,1);
TIME=nan(Ndata,1);
CHAN=nan(Ndata,1);
for inddata=1:Ndata
    
    %query one data value
    str=query(mux,'DATA:REMOVE? 1');
    data=sscanf(str,'%f VDC,%f,%f');
    %data(1) contains the measurement 
    %data(2) contains the time from the scan start
    %data(3) contains the number of channel
    
    DATA(inddata)=data(1);        
    TIME(inddata)=data(2);        
    CHAN(inddata)=data(3);        
end
data1 = DATA(1:4:end);
data2 = DATA(2:4:end);
data3 = DATA(3:4:end);
data4 = DATA(4:4:end);

time1 = TIME(1:4:end);
time2 = TIME(2:4:end);
time3 = TIME(3:4:end);
time4 = TIME(4:4:end);

if ~all(CHAN(1:4:end)==102)
    warning('Uhm, hay algo raro')
end
if ~all(CHAN(2:4:end)==103)
    warning('Uhm, hay algo raro')
end
if ~all(CHAN(3:4:end)==104)
    warning('Uhm, hay algo raro')
end
if ~all(CHAN(4:4:end)==105)
    warning('Uhm, hay algo raro')
end

plot(time1, data1, time2, data2, time3, data3, time4, data4)
xlabel('Tiempo')
ylabel('Medida')
legend('data1','data2','data3','data4')
str=query(mux,'DATA:REMOVE? 10');
%close connection
%close(mux)
dlmwrite('hielo_4canales_5.txt',[time1 data1 time2 data2 time3 data3 time4 data4], '\t');

 %img = mscan;

% Die Messung besteht aus zwei Phasen (Stationäre Rotation, Pullback)
% Während der Pullback Phase werden 20 mm in einer zeitlichen Frequenz 
% von 2 mm pro Sekunde zurückgelegt -> Phasendauer: 10 Sekunden

% Die einzelnen A-scans werden mit einem Abstand von xTime pro Sekunde
% aufgenommen und alle relevanten Daten werden innerhalb der Pullback
% Phase gemessen -> 10 / xTime relevante A-scans, die aus den 
% Gesammtdaten-Matrix in einer neu-exclusiven Matrix gespeichert werden
% müssen

%Pullbackphase: pullT
%pullFrequenccy: pullF
%Pullstrecke: pullLength

clear all
clc
close all


%Laden der Daten
fileID_Bin = fopen('oct_final.bin');

%A ist ein Vektor aus "scanCount" aufgenommenen A-Scans
%1024 Werte repräsentieren einen A-Scan

%scanCount represäntiert die Anzahl der A-Scans
scanCount = 500000;

A = fread(fileID_Bin, 1024*scanCount,'uint16');


A = reshape(A,[1024,scanCount]);


%Die Werte müssen mit der Zahl 540 multipliziert werden
%(ADC-Ticks zu physikalischer Größe)
A = A*540;

%Jeder Sensor hat einen konstanten Offset (B)
B = load('Offset.txt');

%Die Offset-Daten B werden für jeden A-Scan wiederholt
B = ones(1024,scanCount).*B;
%Der Offset wird abgezogen
A = A - B;


clearvars B;

%DC: Der "Direct Current" stellt das Spektrum der Lichtquelle da
dcTerm = mean(A,2);
A = A - dcTerm;



%Die Lichtquelle sendet keine linear verteilte Wellenlängen
Chirp = load('Chirp.txt');

C = zeros(size(A));

%Interpolation der Funktion auf discrete Wellenlängen (s. Chirp) 
 for i=1:scanCount
     C(:,i)=interp1(Chirp,A(:,i),0:1023);
 end
 
clearvars A Chirp

D = zeros(size(C));
 
for i=1:scanCount
     D(:,i) =  C(:,i) .* hann(1024);
end

clearvars C

%Die Fouriertransformation liefert ein komplexes Signal
E=fft(D,1024);
clearvars D

%Der Betrag von E zeigt die Intensität 
%zu den unterschiedlichen Distanzen "z"

%Signal-Kompression: 20*log(X)
Result = real(20*log(E(1:floor(size(E,1)/2),:)));

compData = Result(:,1:100:end);
save('editData_1mil.mat','compData');

imagesc(compData);

colormap gray


  
    

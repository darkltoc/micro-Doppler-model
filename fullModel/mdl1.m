clc; clear; close all;
%% инициализация модели, установка основных параметров
targetType = 'copter';
tgtPosition = 
tgtSpeed = 
traceType = 'TraceReclinear';
operationalFrequency = 
v_max = 
rangeMax = 
rangeResolution = 
radarSpeed = 
radarInitialPosition = 
rxNf = % noise figure
antAperture = 

tr = transmitter(rangeMax, operationalFrequency, v_max,rangeResolution, ...
    radarSpeed, antAperture, rxNf, radarInitialPosition);
rdr = radar(tr,)
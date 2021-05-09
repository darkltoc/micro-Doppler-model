classdef transmitter < handle
    %TRANSMITTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        rangeResolution_            % разрешение по дальности
        v_max_                      % максимальная скорость движения объекта, переводим в м/с
        operationalFrequency_       % central/operating frequency
        rangeMax_                   % дальность unambiguous? (изменение влияет на time-domain)
        wavelength_                 % длина волны излучения
        sweepTime_                  % tm или sweep time
        bandwidth_                  % bw оно же диапазон частот
        sweep_slope_                % sweep_slope / крутизна модуляции
        maxBeatFrequency_           % beat frequency / частота сигнала биений
        maxDopplerShift_            % максимальный допплеровский сдвиг
        beatFrequency_              % beat frequency / частота сигнала биений вместе с доппл. смещением
        sampleRate_                 % частота дискретизации
        radarSpeed_                 % скорость движения платформы радара
        antAperture_                % апертура антенны метры квадратные
        antGain_                    % КУ антенны in dB
        txPpower_                   % передатчик, мощность излучения in watts
        txGain_                     % коэффициент усиления ПРД in dB
        rxGain_                     % коэффициент усиления ПРМ in dB
        rxNf_                       % коэффициент шума in dB
        waveform_                   % форма сигнала
        transmitter_
        receiver_
        txMotion_
    end
    
    properties (Constant = true)
        c_light = 3e8;              % скорость света в вакууме
    end
    
    methods
        function obj = transmitter(rangeMax ,operationalFrequency, v_max,rangeResolution, rspeed, antAperture, rxNf)
            if nargin == 1
                operationalFrequency = 77e9;
                v_max = 230;
                rangeResolution = .5;
                rspeed = 0;
                antAperture = 6.06e-4;
                rxNf = 4.5;
            end
            %TRANSMITTER Construct an instance of this class
            %   Detailed explanation goes here
            obj.wavelength_ = obj.c_light/operationalFrequency;
            obj.sweepTime_ = 5.5*range2time(rangeMax,obj.c_light);
            obj.bandwidth_ = range2bw(rangeResolution,obj.c_light);
            obj.sweep_slope_ = obj.bandwidth_/obj.sweepTime_;
            obj.maxBeatFrequency_ = range2beat(rangeMax,obj.sweep_slope_,obj.c_light);
            obj.maxDopplerShift_ = speed2dop(2*v_max,obj.wavelength_);
            obj.beatFrequency_ = obj.maxBeatFrequency_ + obj.maxDopplerShift_;
            obj.sampleRate_ = max(2*obj.beatFrequency_,obj.bandwidth_);
            obj.radarSpeed_ = rspeed*1000/3600;                        
            obj.antGain_ = aperture2gain(antAperture,obj.wavelength_);                  
            obj.txPpower_ = db2pow(5)*1e-3;                 
            obj.txGain_ = 9 + obj.antGain_;                   
            obj.rxGain_ = 15 + obj.antGain_;
            obj.operationalFrequency_ = operationalFrequency;
            obj.rangeResolution_ = rangeResolution;
            obj.v_max_ = v_max;
            obj.rangeMax_ = rangeMax;
            obj.antAperture_ = antAperture;
            obj.rxNf_ = rxNf;
            obj.waveform_ = phased.FMCWWaveform('SweepTime',obj.sweepTime_,'SweepBandwidth', obj.bandwidth_,... 
            'SampleRate', obj.sampleRate_);
            obj.transmitter_ = phased.Transmitter('PeakPower',obj.txPpower_,'Gain',obj.txGain_);
            obj.receiver_ = phased.ReceiverPreamp('Gain',obj.rxGain_,'NoiseFigure',obj.rxNf_,...
            'SampleRate',obj.sampleRate_);
            obj.txMotion_ = phased.Platform('InitialPosition',[0;0;0.5],...
            'Velocity',[obj.radarSpeed_;0;0]);
        end
        
       % --- pulse sequence start positions in 't' series пробно добавим
        function d = pulseTrigger( obj, t)
            for k = 1:size(t, 1)
                d = (ceil( t(k,1)/obj.sweepTime_ ) * obj.sweepTime_ : obj.sweepTime_ : t(k,end) )';
                if ~isempty(d) 
                    return
                end
            end
        end
        
    end
end


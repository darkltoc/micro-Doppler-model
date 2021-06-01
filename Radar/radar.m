classdef radar
    %RADAR Summary of this class goes here
    %   параметры цели, канала распространения и моделирование излучения
    
    
    properties (Access = public)
%         transmitter_
        tgtDist_            % дистанция до цели в метрах
        tgtSpeed_           % скорость цели в м/с
        tgtRCS_             % эпо цели в дБ
        tgt_                % объект цели с заданными параметрами
        tgMotion_           % объект платформы цели с заданными векторами движения
        channel_            % объект канала распространения ЭМВ
        sampleRate_
    end
    
    properties (Constant = true)
        c_light = 3e8;              % скорость света в вакууме
    end
    
    methods
        function obj = radar(transmitter, distance, speed, RCS)
            if nargin == 1 
                distance = [43; 0; 0.5];
                speed = [96; 0; 0];
            end            
%             obj.transmitter_ = transmitter; 
            obj.sampleRate_ = transmitter.sampleRate_;
            obj.tgtDist_ = distance;
            obj.tgtSpeed_ = speed*1000/3600;
            obj.tgtRCS_ = db2pow(min(10*log10(obj.tgtDist_(1))+5,20));
            obj.tgt_ = phased.RadarTarget('MeanRCS',obj.tgtRCS_,'PropagationSpeed',obj.c_light,...
            'OperatingFrequency',transmitter.operationalFrequency_);
            obj.tgMotion_ = phased.Platform('InitialPosition',obj.tgtDist_,...
            'Velocity',obj.tgtSpeed_);
            obj.channel_ = phased.FreeSpace('PropagationSpeed',obj.c_light,...
            'OperatingFrequency',transmitter.operationalFrequency_,...
            'SampleRate',transmitter.sampleRate_,'TwoWayPropagation',true);
            
        end
        
       
    end        
end




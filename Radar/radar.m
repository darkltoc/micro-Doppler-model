classdef radar
    %RADAR Summary of this class goes here
    %   параметры цели, канала распространения и моделирование излучения
    
    
    properties
        transmitter_
        tgtDist_            % дистанция до цели в метрах
        tgtSpeed_           % скорость цели в м/с
        tgtRCS_             % эпо цели в дБ
        tgt_                % объект цели с заданными параметрами
        tgMotion_           % объект платформы цели с заданными векторами движения
        channel_            % объект канала распространения ЭМВ
    end
    
    properties (Constant = true)
        c_light = 3e8;              % скорость света в вакууме
    end
    
    methods
        function obj = radar(transmitter)
            if nargin > 0 
                distance = 56;
                speed = 96;
            end                 
            obj.transmitter_ = transmitter;
            obj.tgtDist_ = distance;
            obj.tgtSpeed_ = speed*1000/3600;
            obj.tgtRCS_ = db2pow(min(10*log10(obj.tgtDist_)+5,20));
            obj.tgt_ = phased.RadarTarget('MeanRCS',obj.tgtRCS_,'PropagationSpeed',obj.c_light,...
            'OperatingFrequency',obj.transmitter_.operationalFrequency_);
            obj.tgMotion_ = phased.Platform('InitialPosition',[obj.tgtDist_;0;0.5],...
            'Velocity',[obj.tgtSpeed_;0;0]);
            obj.channel_ = phased.FreeSpace('PropagationSpeed',obj.c_light,...
            'OperatingFrequency',obj.transmitter_.operationalFrequency_,...
            'SampleRate',obj.transmitter_.sampleRate_,'TwoWayPropagation',true);
            
        end
        % необходимо добавить функцию или что-то для излучения и вывода.
        function spectrum = specanalyzer ()
        end
        
%         function imageTrace( obj, tracePulses )
%             imagesc( obj.rangeLim_, ...
%                      [ 0  size(tracePulses,1) ] * obj.transmitter_.period_, ...
%                      real(tracePulses))
%         end
    end
end

% channel 1 - received signal, channel 2 - dechirped signal
% From the spectrum scope, one can see that although the received signal is wideband (channel 1),
% sweeping through the entire bandwidth, the dechirped signal becomes narrowband (channel 2).
specanalyzer = dsp.SpectrumAnalyzer('SampleRate',Fs,...
    'PlotAsTwoSidedSpectrum',true,...
    'Title','Spectrum for received and dechirped signal',...
    'ShowLegend',true);

rng(2012);
Nsweep = 64;
xr = complex(zeros(waveform.SampleRate*waveform.SweepTime,Nsweep));

% simulation loop
for m = 1:Nsweep
    % Update radar and target positions
    [radar_pos,radar_vel] = radarmotion(waveform.SweepTime);
    [tgt_pos,tgt_vel] = tg_motion(waveform.SweepTime);

    % Transmit FMCW waveform
    sig = waveform();
    txsig = transmitter(sig);

    % Propagate the signal and reflect off the target
    txsig = channel(txsig,radar_pos,tgt_pos,radar_vel,tgt_vel);
    txsig = tg_target(txsig);

    % Dechirp the received radar return
    txsig = receiver(txsig);
    dechirpsig = dechirp(txsig,sig);

    % Visualize the spectrum
%     specanalyzer([txsig dechirpsig]);

    xr(:,m) = dechirpsig;
end


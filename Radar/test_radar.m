% test radar
clc
clear
close all

tr = transmitter(100); % rangeMax 
rdr = radar( tr );
% % Visualize the spectrum

% channel 1 - received signal, channel 2 - dechirped signal
% From the spectrum scope, one can see that although the received signal is wideband (channel 1),
% sweeping through the entire bandwidth, the dechirped signal becomes narrowband (channel 2).


%     specanalyzer([txsig dechirpsig]);
specanalyzer = dsp.SpectrumAnalyzer('SampleRate',tr.sampleRate_,...
    'PlotAsTwoSidedSpectrum',true,...
    'Title','Spectrum for received and dechirped signal',...
    'ShowLegend',true);
    
       
rng(2012);
Nsweep = 2^10;
xr = complex(zeros(tr.waveform_.SampleRate*tr.waveform_.SweepTime,Nsweep));

% simulation loop
for m = 1:Nsweep
    % Update radar and target positions
    [radar_pos,radar_vel] = tr.txMotion_(tr.waveform_.SweepTime);
    [tgt_pos,tgt_vel] = rdr.tgMotion_(tr.waveform_.SweepTime);

    % Transmit FMCW waveform
    sig = tr.waveform_();  
    txsig = tr.transmitter_(sig);

    % Propagate the signal and reflect off the target
    txsig = rdr.channel_(txsig,radar_pos,tgt_pos,radar_vel,tgt_vel);
    txsig = rdr.tgt_(txsig);

    % Dechirp the received radar return
    txsig = tr.receiver_(txsig);
    dechirpsig = dechirp(txsig,sig);

    % Visualize the spectrum
    specanalyzer([txsig dechirpsig])    

    xr(:,m) = dechirpsig;
end

rngdopresp = phased.RangeDopplerResponse('PropagationSpeed',tr.c_light,...
    'DopplerOutput','Speed','OperatingFrequency',tr.operationalFrequency_,...
    'SampleRate',tr.sampleRate_,'RangeMethod','FFT','SweepSlope',tr.sweep_slope_,...
    'RangeFFTLengthSource','Property','RangeFFTLength',2048,...
    'DopplerFFTLengthSource','Property','DopplerFFTLength',256);

clf;
plotResponse(rngdopresp,xr);                     % Plot range Doppler map
axis([-tr.v_max_ tr.v_max_ 0 tr.rangeMax_])
clim = caxis;


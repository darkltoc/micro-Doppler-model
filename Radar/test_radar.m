% test radar
clc
clear
close all

tr = transmitter(100); % rangeMax 
rdr = radar( tr );
% % Visualize the spectrum
%     specanalyzer([txsig dechirpsig]);
specanalyzer = dsp.SpectrumAnalyzer('SampleRate',tr.sampleRate_,...
    'PlotAsTwoSidedSpectrum',true,...
    'Title','Spectrum for received and dechirped signal',...
    'ShowLegend',true);
    
       
rng(2012);
Nsweep = 2^13;
xr = complex(zeros(tr.waveform_.SampleRate*tr.waveform_.SweepTime,Nsweep));

% simulation loop
for m = 1:Nsweep
    % Update radar and target positions
    [radar_pos,radar_vel] = tr.txMotion_(tr.waveform_.SweepTime);
    [tgt_pos,tgt_vel] = rdr.tgMotion_(tr.waveform_.SweepTime);

    % Transmit FMCW waveform
    sig = tr.waveform_(); % too Too many input arguments. Expected 0 (in addition to System object), g
    txsig = tr.transmitter_(sig);

    % Propagate the signal and reflect off the target
    txsig = rdr.channel_(txsig,radar_pos,tgt_pos,radar_vel,tgt_vel);
    txsig = rdr.tgt_(txsig);

    % Dechirp the received radar return
    txsig = tr.receiver_(txsig);
    dechirpsig = dechirp(txsig,sig);

    % Visualize the spectrum
    specanalyzer([txsig dechirpsig])    % specanalyzer([txsig dechirpsig]);

    xr(:,m) = dechirpsig;
end


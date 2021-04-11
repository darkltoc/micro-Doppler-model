clc
clear
close all
%% модель и параметры РЛ cbuyfkf ?
f0 = 77e9; % central/operating frequency
c_light = 3e8; 
wavelength = c_light/f0;
range_max = 200; % дальность до цели или дальность unambiguous? (изменение влияет на time-domain)
T = 5.5*range2time(range_max,c_light); % tm или sweep time
range_res = 1; % разрешение по дальности
B = range2bw(range_res,c_light); % bw оно же диапазон частот
k = B/T; % sweep_slope / крутизна модуляции??
fr_max = range2beat(range_max,k,c_light); % beat frequency / частота сигнала биений
v_max = 230*1000/3600; % максимальная скорость движения объекта, переводим в м/с
fd_max = speed2dop(2*v_max,wavelength); % максимальный допплеровский сдвиг

fb_max = fr_max+fd_max; % beat frequency / частота сигнала биений вместе с доппл. смещением

Fs = max(2*fb_max,B); % частота дискретизации

%% Сигнал

waveform = phased.FMCWWaveform('SweepTime',T,'SweepBandwidth', B,... 
    'SampleRate', Fs);
sig = waveform();
%% построение графиков
sig = waveform();
subplot(211); plot(0:1/Fs:T-1/Fs,real(sig));
xlabel('Time (s)'); ylabel('Amplitude (v)');
title('FMCW signal'); axis tight;
subplot(212); spectrogram(sig,32,16,32,Fs,'yaxis');
title('FMCW signal spectrogram');

%% модель и параметры цели (автомобиля)
tg_dist = 43; % дистанция до цели в метрах
tg_speed = 96*1000/3600; % скорость цели в м/с
tg_rcs = db2pow(min(10*log10(tg_dist)+5,20)); % эпо цели в дБ

tg_target = phased.RadarTarget('MeanRCS',tg_rcs,'PropagationSpeed',c_light,...
    'OperatingFrequency',f0);
tg_motion = phased.Platform('InitialPosition',[tg_dist;0;0.5],...
    'Velocity',[tg_speed;0;0]);

channel = phased.FreeSpace('PropagationSpeed',c_light,...
    'OperatingFrequency',f0,'SampleRate',Fs,'TwoWayPropagation',true);

%% модель и параметры РЛС??

ant_aperture = 6.06e-4;                         % апертура антенны метры квадратные
ant_gain = aperture2gain(ant_aperture,wavelength);  % КУ антенны in dB

tx_ppower = db2pow(5)*1e-3;                     % передатчик, мощность излучения in watts
tx_gain = 9+ant_gain;                           % коэффициент усиления ПРД in dB

rx_gain = 15+ant_gain;                          % коэффициент усиления ПРМ in dB
rx_nf = 4.5;                                    % коэффициент шума in dB

transmitter = phased.Transmitter('PeakPower',tx_ppower,'Gain',tx_gain);
receiver = phased.ReceiverPreamp('Gain',rx_gain,'NoiseFigure',rx_nf,...
    'SampleRate',Fs);

radar_speed = 100*1000/3600; % полагаем радар статичным, скорость = 0
radarmotion = phased.Platform('InitialPosition',[0;0;0.5],...
    'Velocity',[radar_speed;0;0]);

%% моделирование излучения

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

%% Range and Doppler Estimation
% тестовый график 
rngdopresp = phased.RangeDopplerResponse('PropagationSpeed',c_light,...
    'DopplerOutput','Speed','OperatingFrequency',f0,'SampleRate',Fs,...
    'RangeMethod','FFT','SweepSlope',k,...
    'RangeFFTLengthSource','Property','RangeFFTLength',2048,...
    'DopplerFFTLengthSource','Property','DopplerFFTLength',256);

clf;
plotResponse(rngdopresp,xr);                     % Plot range Doppler map
axis([-v_max v_max 0 range_max])
clim = caxis;



Dn = fix(Fs/(2*fb_max));
for m = size(xr,2):-1:1
    xr_d(:,m) = decimate(xr(:,m),Dn,'FIR');
end
fs_d = Fs/Dn;

% To estimate the range, firstly, the beat frequency is estimated using
% the coherently integrated sweeps and then converted to the range.

% здесь нужно применить тот алгоритм из диссера
% fb_rng = rootmusic(pulsint(xr_d,'coherent'),1,fs_d);
fb_rng = rootmusic(pulsint(xr_d,'coherent'),1,fs_d);
rng_est = beat2range(fb_rng,k,c_light)
% Second, the Doppler shift is estimated across the sweeps at the range where the target is present.
peak_loc = val2ind(rng_est,c_light/(fs_d*2));
fd = -rootmusic(xr_d(peak_loc,:),1,1/T);
v_est = dop2speed(fd,wavelength)/2

%% Range Doppler Coupling Effect

% Besides, given the velocity of a car, there is no need to make measurements
% every 7 microseconds. Hence, automotive radars often use a longer sweep time.
% For example, the waveform used in [2] has the same parameters as the waveform designed
% in this example except a sweep time of 2 ms.
% 
% A longer sweep time makes the range Doppler coupling more prominent.
% To see this effect, first reconfigure the waveform to use 2 ms as the sweep time.
waveform_tr = clone(waveform);
release(waveform_tr);
T = 2e-3;
waveform_tr.SweepTime = T;
k = B/T;

deltaR = rdcoupling(fd,k,c_light)
v_unambiguous = dop2speed(1/(2*T),wavelength)/2


%% пояснения к fmcw model, почему и как выбираем
% 
% In an ACC setup, the maximum range the radar needs to monitor is around 
% 200 m and the system needs to be able to distinguish two targets 
% that are 1 meter apart. From these requirements, one can compute the waveform parameters.
% 
% The sweep time can be computed based on the time needed for the signal 
% to travel the unambiguous maximum range. In general, for an FMCW radar system,
% the sweep time should be at least 5 to 6 times the round trip time. This example uses a factor of 5.5.
% 
% The sweep bandwidth can be determined according to the range resolution 
% and the sweep slope is calculated using both sweep bandwidth and sweep time.

%% ВЫБОР ЧАСТОТЫ ДИСКРЕТИЗАЦИИ СИГНАЛА

% Because an FMCW signal often occupies a huge bandwidth, 
% setting the sample rate blindly to twice the bandwidth often stresses 
% the capability of A/D converter hardware. To address this issue, one can often choose a lower sample rate.
% Two things can be considered here:
% 1. For a complex sampled signal, the sample rate can be set to the same as the bandwidth.
% 2. FMCW radars estimate the target range using the beat frequency embedded 
% in the dechirped signal. The maximum beat frequency the radar needs to detect
% is the sum of the beat frequency corresponding to the maximum range and 
% the maximum Doppler frequency. Hence, the sample rate only needs to be twice the maximum beat frequency.

%%  после этого следующие параметры
System parameters            Value
----------------------------------
Operating frequency (GHz)    77
Maximum target range (m)     200
Range resolution (m)         1
Maximum target speed (km/h)  230
Sweep time (microseconds)    7.33
Sweep bandwidth (MHz)        150
Maximum beat frequency (MHz) 27.30
Sample rate (MHz)            150

%% модель и параметры цели (авто)
% The target of an ACC radar is usually a car in front of it. This example
% assumes the target car is moving 50 m ahead of the car with the radar,
% at a speed of 96 km/h along the x-axis.

% The propagation model is assumed to be free space.
% (задаём переменную channel)
%% модель и параметры РЛС
% The rest of the radar system includes the transmitter, the receiver,
% and the antenna. This example uses the parameters presented in [1].
% Note that this example models only main components and omits the effect 
% from other components, such as coupler and mixer. In addition, for the sake
%     of simplicity, the antenna is assumed to be isotropic and the gain 
%     of the antenna is included in the transmitter and the receiver.
% 
% Automotive radars are generally mounted on vehicles, so they are often in motion.
% This example assumes the radar is traveling at a speed of 100 km/h along x-axis.
% So the target car is approaching the radar at a relative speed of 4 km/h.

%% симуляция радиоизлучения 
% As briefly mentioned in earlier sections, an FMCW radar measures the range 
% by examining the beat frequency in the dechirped signal. To extract this frequency,
% a dechirp operation is performed by mixing the received signal with the transmitted signal. 
% After the mixing, the dechirped signal contains only individual frequency components 
% that correspond to the target range.
% 
% In addition, even though it is possible to extract the Doppler information
% from a single sweep, the Doppler shift is often extracted among several sweeps
% because within one pulse, the Doppler frequency is indistinguishable from 
% the beat frequency. To measure the range and Doppler, an FMCW radar typically performs 
% the following operations:
% 
% 1. The waveform generator generates the FMCW signal.
% 
% 2. The transmitter and the antenna amplify the signal and radiate the signal into space.
% 
% 3. The signal propagates to the target, gets reflected by the target, and travels back to the radar.
% 
% 4. The receiving antenna collects the signal.
% 
% 5. The received signal is dechirped and saved in a buffer.
% 
% 6. Once a certain number of sweeps fill the buffer, the Fourier transform 
% is performed in both range and Doppler to extract the beat frequency as well 
% as the Doppler shift. One can then estimate the range and speed of the target
% using these results. Range and Doppler can also be shown as an image and 
% give an intuitive indication of where the target is in the range and speed domain.

% The next section simulates the process outlined above. A total of 64 sweeps
% are simulated and a range Doppler response is generated at the end.
% 
% During the simulation, a spectrum analyzer is used to show the spectrum 
% of each received sweep as well as its dechirped counterpart.
% 
%% Range and Doppler Estimation
% Before estimating the value of the range and Doppler, 
% it may be a good idea to take a look at the zoomed range Doppler response of all 64 sweeps.
% From the range Doppler response, one can see that the car in front is
% a bit more than 40 m away and appears almost static. This is expected 
% because the radial speed of the car relative to the radar is only 4 km/h,
% which translates to a mere 1.11 m/s.
% 
% There are many ways to estimate the range and speed of the target car. 
% For example, one can choose almost any spectral analysis method to extract
% both the beat frequency and the Doppler shift. This example uses 
% the root MUSIC algorithm to extract both the beat frequency and the Doppler shift.
% 
% As a side note, although the received signal is sampled at 150 MHz so
% the system can achieve the required range resolution, after the dechirp, 
% one only needs to sample it at a rate that corresponds to the maximum beat frequency.
% Since the maximum beat frequency is in general less than the required sweeping bandwidth,
% the signal can be decimated to alleviate the hardware cost. The following 
% code snippet shows the decimation process.

%% Range Doppler Coupling Effect
% One issue associated with linear FM signals, such as an FMCW signal, 
% is the range Doppler coupling effect. As discussed earlier, the target range
% corresponds to the beat frequency. Hence, an accurate range estimation depends on 
% an accurate estimate of beat frequency. However, the presence of Doppler shift
% changes the beat frequency, resulting in a biased range estimation.

% For the situation outlined in this example, the range error caused by
% the relative speed between the target and the radar is deltaR = rdcoupling(fd,sweep_slope,c)

% This error is so small that we can safely ignore it.
% 
% Even though the current design is achieving the desired performance,
% one parameter warrants further attention. In the current configuration,
% the sweep time is about 7 microseconds. Therefore, the system needs 
% to sweep a 150 MHz band within a very short period. Such an automotive radar
% may not be able to meet the cost requirement. Besides, given the velocity of a car, 
% there is no need to make measurements every 7 microseconds. Hence, automotive radars 
% often use a longer sweep time. For example, the waveform used in [2] has the same parameters
% as the waveform designed in this example except a sweep time of 2 ms.

% A longer sweep time makes the range Doppler coupling more prominent. 
% To see this effect, first reconfigure the waveform to use 2 ms as the sweep time.
% 

% References
% [1] Karnfelt, C. et al.. 77 GHz ACC Radar Simulation Platform, 
% IEEE International Conferences on Intelligent Transport Systems Telecommunications (ITST), 2009.
% 
% [2] Rohling, H. and M. Meinecke. Waveform Design Principle for Automotive Radar Systems, 
% Proceedings of CIE International Conference on Radar, 2001.

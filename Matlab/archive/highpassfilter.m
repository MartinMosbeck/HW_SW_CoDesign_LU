IIRFilterOrder = 10;
Fpass = 15;
Nth=16;
Fs=2.5*10^6/Nth;
IIRCoeff = designfilt('highpassiir', 'FilterOrder', IIRFilterOrder, ...
          'PassbandFrequency', Fpass, ...
          'StopbandAttenuation', 60, 'PassbandRipple', 1, ...
          'SampleRate', Fs, 'DesignMethod', 'ellip');
fvtool(IIRCoeff, 'Fs',Fs);
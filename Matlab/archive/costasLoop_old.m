% In this program I have described a very simple yet effective way of
% applying a costas loop in receiving a DSB-SC signal with unknown phase
% offset in carrier. The basic contruction of a costas receiver includes
% Low pass filters and Voltage controlled oscillator with central frequency
% same as carrier frequency.
% 
% For applying a low pass filter a simple Integrator can be used. In
% digital domain integrator can be replaced by summator and hence I have
% replaced integrator with summator which generate output summing previous
% Tc/Ts samples, where Tc is period of carrier wave
%                      Ts is sampling time
% The reason is we are considering integrator as y(t) = int(x(t)) from 0 to
% Tc. For this approximate lowpass filter best bandwidth achieved is 200Hz 
% so consider this before designing your message.
% The VCO operation can be approximated as 
% phi(i) = phi(i-1) - sign(.25*m(t)*sin(phi(i-1))*cos(phi(i-1)));
% That is, if phase of carrier is greater than VCO phase then we increase
% phase in next iteration and vice versa.
% After doing iteration all over sample we will get our desired message
% signal and will get initial phase offset applied to input carrier.
% ------------------------------------------------------------------------
% For any suggestions please contact :
% gauravgg@iitk.ac.in
% gaurav71531@gmail.com
% ------------------------------------------------------------------------
% --------------------------GENERATOR PART--------------------------------
% Lets generate a sample input signal with known phase offset or you can
% use your own signal 
t = 0:160000;                 % time scale
fs = 250000;                    % Sampling Frequency
fc = 2375;                   % Carrier Frequency 

m = square(2*pi*150*t/fs);      % sample message signal
c = exp(1i*2*pi*fc*t/fs + pi/3); % carrier signal with phase offset

st = m.*c;                   % DSB-SC signal
figure
plot(st, 'g');
% -----------------------------------------------------------------------

% ---------------------------RECEIVER PART-------------------------------
N = length(st);              
t = 0:1:N-1;                 % Time vector
phi = zeros(1,N);            % Phase vector of VCO initialize
s1 = zeros(1,N); 
s2 = zeros(1,N);
y1 = zeros(1,N);
y2 = zeros(1,N);

for n = 1:N
    
    if n>1
% The step in which phase is changed is pi*5*10*-5, it can be varied.        
       
        phi(n) = phi(n-1) - (5*10^-5)*pi*sign(y1(n-1)*y2(n-1));
    end
    
    s1(n) = real(st(n)) * cos(2*pi*fc*t(n)/fs  + phi(n));
    s2(n) = imag(st(n)) * sin(2*pi*fc*t(n)/fs  + phi(n));

% -----------------------INTEGRATOR------------------------------------
    if n<=100
%  If sample index is less than 100 (Tc/Ts) then we sum available previous
%  samples
        for j=1:n
            y1(n) = y1(n) + s1(j);
            y2(n) = y2(n) + s2(j);
        end
      
    else
% Summing previous 100 (Tc/Ts) values        
        for j = n-99:n
            y1(n) = y1(n) + s1(j);
            y2(n) = y2(n) + s2(j);
        end
    end
%----------------------------------------------------------------------    
end

figure;
plot(t,y1);title('Output signal');
figure;
plot(t,phi);title('phase for Signal vs time');

%For getting initial phase of carrier wave we approximate it with final
%value of phase attained by our VCO

phase = phi(end);
disp(phase);

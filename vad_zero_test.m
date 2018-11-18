clc;clear;

Fs = 48000;
file1 = 'low.wav';
[s,fs]=audioread(file1, 'native');
if(fs ~= Fs)
  s = resample(s, Fs, fs);  
end
s = s / 10;
s = double(s(:,1))./32768;

%s=s+(rand(length(s),1)-0.5)*sqrt(12*0.0001);

t=20;

frameL = 2048;

for i=1:length(s)/frameL

    tmp=s((i-1)*frameL+1:i*frameL);

    ste(i)=sum(tmp.^2);

    zcc(i)=sum(tmp(1:end-1).*tmp(2:end)<0);

end

subplot(311);plot(s);title('Speech Signal');xlabel('Sample');

subplot(312);plot(ste);title('Short time energy');xlabel('Frame');

subplot(313);plot(zcc);title('Zerocrossing counter');xlabel('Frame');

t_e=1; % threshold of STE

t_z=150; % threshold of ZCC

vad=(ste>t_e).*(zcc<t_z);

detect=ones(length(s),1);

for i=1:length(ste);
    detect((i-1)*frameL+1:i*frameL)=vad(i);
end

figure;plot(s),hold on; plot(detect*0.1);
axis([0,500000, -0.2, 0.2]);

title('Signal and VAD');legend('Signal','VAD');xlabel('sample');

hold off;

figure;speech=s(detect==1);plot(speech);

title('non-speech signal removed');
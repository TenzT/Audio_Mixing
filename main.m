clear;clc;


%%% 参数设置 %%%
r = 100;  % 往前读的帧数
N = 2048; % 每帧抽样点数
Fs = 48000; % 音频采样率


%%% 读入一路信号并处理 %%%
file1 = 'interval.wav';
[data1 fs1] = audioread(file1, 'native');
data1 = data1 * 10;

file2 = 'low.wav';
[data2 fs2] = audioread(file2, 'native');
data2 = data2 / 10;

file3 = 'low_high.wav';
[data3 fs3] = audioread(file3, 'native');
data3 = data3 ;

% 若采样率不足,重采样成48kHz
if(fs1 ~= Fs)
  data1 = resample(data1, Fs, fs1);  
end
if(fs2 ~= Fs)
    data2 = resample(data2, Fs, fs2);  
end
if(fs3 ~= Fs)
    data2 = resample(data2, Fs, fs2);  
end

% 变成单声道信号并将另一个维度变成VAD标志
data1(:, 2) = ones(size(data1, 1),1);
data1 = data1';

data2(:, 2) = ones(size(data2, 1),1);
data2 = data2';

data3(:, 2) = ones(size(data3, 1),1);
data3 = data3';

% 截断信号使得抽样点成为整数帧
max_length = min([size(data1, 2),size(data2, 2), size(data3,2)]);
data1 = data1(:, 1:N * (floor(max_length/N)-1));
data2 = data2(:, 1:N * (floor(max_length/N)-1));
data3 = data3(:, 1:N * (floor(max_length/N)-1));

NFrame = size(data1, 2)/N;

%%% 遍历所有帧
for i = 1:NFrame
    
%-------- 获取当前帧VAD ------------
    % 基于短时功率和过零率得到VAD
    if (i<101)
        % 第一路信号
        [vad_detected, vad_now]= vad_zero(data1(:, 1+(i-1)*N:i*N));
        % 更新当前帧的VAD值
        data1(2, 1+(i-1)*N:i*2048) = vad_detected;

        % 第二路信号
        [vad_detected, vad_now]= vad_zero(data2(:, 1+(i-1)*N:i*N));
        % 更新当前帧的VAD值
        data2(2, 1+(i-1)*N:i*2048) = vad_detected;

        % 第三路信号.....
        [vad_detected, vad_now]= vad_zero(data3(:, 1+(i-1)*N:i*N));
        % 更新当前帧的VAD值
        data3(2, 1+(i-1)*N:i*2048) = vad_detected;
    end

    % 当超过100帧时候，使用论文的VAD算法
    if (i>=101)
        % 第一路信号
        [vad_detected, vad_now]= vad(data1(:, 1+(i-101)*N:i*N));
        % 更新当前帧的VAD值
        data1(2, 1+(i-1)*N:i*2048) = vad_detected;

        % 第二路信号
        [vad_detected, vad_now]= vad(data2(:, 1+(i-101)*N:i*N));
        % 更新当前帧的VAD值
        data2(2, 1+(i-1)*N:i*2048) = vad_detected;

        % 第三路信号.....
        [vad_detected, vad_now]= vad(data3(:, 1+(i-101)*N:i*N));
        % 更新当前帧的VAD值
        data3(2, 1+(i-1)*N:i*2048) = vad_detected;

    end
%---------------------------------

    % 当前帧的数据，提取出来方便后面处理
    this_frame1 = data1(:, 1+(i-1)*N:i*2048);
    this_frame2 = data2(:, 1+(i-1)*N:i*2048);
    this_frame3 = data3(:, 1+(i-1)*N:i*2048);

%-------利用vad+now来计算滤波器和响度处理--------


end

% 观察vad是否正确
figure;
title('第一路信号');
subplot(211);
plot(data1(1,:));
axis([0,500000, -4e4, 4e4]);
subplot(212);
plot(data1(2,:));
axis([0,500000, -1, 2]);

figure;
title('第二路信号');
subplot(211);
plot(data2(1,:));
axis([0,500000, -4e4, 4e4]);
subplot(212);
plot(data2(2,:));
axis([0,500000, -1, 2]); 

figure;
title('第三路信号');
subplot(211);
plot(data3(1,:));
axis([0,500000, -4e4, 4e4]);
subplot(212);
plot(data3(2,:));
axis([0,500000, -1, 2]); 
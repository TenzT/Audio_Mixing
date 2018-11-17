clear;clc;


%%% 参数设置 %%%
r = 100;  % 往前读的帧数
N = 2048; % 每帧抽样点数
Fs = 48000; % 音频采样率


%%% 读入一路信号并处理 %%%
file1 = 'vadtest.wav';
[data1 fs] = audioread(file1, 'native');

% 若采样率不足,重采样成48kHz
if(fs ~= Fs)
  data1 = resample(data, Fs, fs);  
end

% 变成单声道信号并将另一个维度变成VAD标志
data1(:, 2) = ones(size(data1, 1),1);
data1 = data1';
% sound(data1,Fs);

% 截断信号使得抽样点成为整数帧
data1 = data1(:, 1:N * floor(size(data1,2)/N));
% data1(1,:) = data1(1,:)/max(data1(1,:)) * (2*16384);

% 自己生成信号做对比
data2 = randn(2,size(data1,2));
data2(2,:) = 1;
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

    end
%---------------------------------

    % 当前帧的数据，提取出来方便后面处理
    this_frame1 = data1(:, 1+(i-1)*N:i*2048);

%-------利用vad+now来计算滤波器和响度处理--------


end

% 观察vad是否正确
subplot(211);
plot(data1(1,:));
subplot(212);
plot(data1(2,:));
axis([0,500000, -1, 2]);

figure;
subplot(211);
plot(data2(1,:));
subplot(212);
plot(data2(2,:));
axis([0,500000, -1, 2]);  
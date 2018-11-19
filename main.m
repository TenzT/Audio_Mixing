clear;clc;close all;

%%% �������� %%%
r = 100;  % ��ǰ����֡��
N = 2048;% ÿ֡��������
Fs = 48000;% ��Ƶ������

%%% ����һ·�źŲ����� %%%
file1 = 'interval.wav';
[data1 fs1] = audioread(file1, 'native');
data1 = data1 * 10;

file2 = 'low.wav';
[data2 fs2] = audioread(file2, 'native');
data2 = data2 / 10;

file3 = 'low_high.wav';
[data3 fs3] = audioread(file3, 'native');
data3 = data3 ;

% �������ʲ���,�ز�����48kHz
if(fs1 ~= Fs)
  data1 = resample(data1, Fs, fs1);  
end
if(fs2 ~= Fs)
    data2 = resample(data2, Fs, fs2);  
end
if(fs3 ~= Fs)
    data2 = resample(data2, Fs, fs2);  
end

% ��ɵ������źŲ�����һ��ά�ȱ��VAD��־
data1(:, 2) = ones(size(data1, 1),1);
data1 = data1';

data2(:, 2) = ones(size(data2, 1),1);
data2 = data2';

data3(:, 2) = ones(size(data3, 1),1);
data3 = data3';

% �ض��ź�ʹ�ó������Ϊ����֡
max_length = min([size(data1, 2),size(data2, 2), size(data3,2)]);
data1 = data1(:, 1:N * (floor(max_length/N)-1));
data2 = data2(:, 1:N * (floor(max_length/N)-1));
data3 = data3(:, 1:N * (floor(max_length/N)-1));

NFrame = size(data1, 2)/N;

%%% ��������֡
for i = 1:NFrame
    
%-------- ��ȡ��ǰ֡VAD ------------
     % ���ڶ�ʱ���ʺ͹����ʵõ�VAD
    if (i<101)
        % ��һ·�ź�
        [vad_detected1, vad_now1]= vad_zero(data1(:, 1+(i-1)*N:i*N));
        % ���µ�ǰ֡��VADֵ
        data1(2, 1+(i-1)*N:i*2048) = vad_detected1;

        % �ڶ�·�ź�
        [vad_detected2, vad_now2]= vad_zero(data2(:, 1+(i-1)*N:i*N));
        % ���µ�ǰ֡��VADֵ
        data2(2, 1+(i-1)*N:i*2048) = vad_detected2;

        % ����·�ź�
        [vad_detected3, vad_now3]= vad_zero(data3(:, 1+(i-1)*N:i*N));
        % ���µ�ǰ֡��VADֵ
        data3(2, 1+(i-1)*N:i*2048) = vad_detected3;
    end

     % ������100֡ʱ��ʹ�����ĵ�VAD�㷨
    if (i>=101)
        % ��һ·�ź�
        [vad_detected, vad_now1]= vad(data1(:, 1+(i-101)*N:i*N));
        % ���µ�ǰ֡��VADֵ
        data1(2, 1+(i-1)*N:i*2048) = vad_detected;

        % �ڶ�·�ź�
        [vad_detected, vad_now2]= vad(data2(:, 1+(i-101)*N:i*N));
        % ���µ�ǰ֡��VADֵ
        data2(2, 1+(i-1)*N:i*2048) = vad_detected;

        % ����·�ź�
        [vad_detected, vad_now3]= vad(data3(:, 1+(i-101)*N:i*N));
        % ���µ�ǰ֡��VADֵ
        data3(2, 1+(i-1)*N:i*2048) = vad_detected;

    end
%---------------------------------

    % ��ǰ֡�����ݣ���ȡ����������洦��
    this_frame1 = data1(:, 1+(i-1)*N:i*2048);
    this_frame2 = data2(:, 1+(i-1)*N:i*2048);
    this_frame3 = data3(:, 1+(i-1)*N:i*2048);
%��������������������������������������������
%                   �˲�
%��������������������������������������������
    %��������ת��
    this_frame1=double(this_frame1);
    this_frame2=double(this_frame2);
    this_frame3=double(this_frame3);
    %�����ݰ�֡�����˲�
    ii=i-1;
    dataout1(1+(ii*2048):2048+(ii*2048)) = filter_time_variant(this_frame1(1,:),this_frame1(2,1));
    dataout2(1+(ii*2048):2048+(ii*2048)) = filter_time_variant(this_frame2(1,:),this_frame2(2,1));
    dataout3(1+(ii*2048):2048+(ii*2048)) = filter_time_variant(this_frame3(1,:),this_frame3(2,1));
    % ��ǰ֡�˲�������ݣ���ȡ����������洦��
    dataout_thisframe1=dataout1(1+(ii*2048):2048+(ii*2048));
    dataout_thisframe2=dataout1(1+(ii*2048):2048+(ii*2048));
    dataout_thisframe3=dataout1(1+(ii*2048):2048+(ii*2048));


%-------����vad+now�������˲�������ȴ���--------


end

% �۲�vad�Ƿ���ȷ
figure;
subplot(211);
plot(data1(1,:));
title('��һ·�ź�');
xlabel('��������'); ylabel('��ֵ');
axis([0,500000, -4e4, 4e4]);
subplot(212);
plot(data1(2,:));
xlabel('��������'); ylabel('VAD');
axis([0,500000, -1, 2]);

%��ͼ�Ƚ�
figure;
plot(1:1:size(data1,2),data1(1,1:1:size(data1,2)),'r',1:1:size(data1,2),dataout1(1:1:size(data1,2)))
xlabel('��������'); ylabel('��ֵ');
legend('�˲�ǰ������' , '�˲��������');

figure;
subplot(211);
plot(data2(1,:));
xlabel('��������'); ylabel('��ֵ');
title('�ڶ�·�ź�');
axis([0,500000, -4e4, 4e4]);
subplot(212);
plot(data2(2,:));
xlabel('��������'); ylabel('VAD');
axis([0,500000, -1, 2]); 

%��ͼ�Ƚ�
figure;
plot(1:1:size(data2,2),data2(1,1:1:size(data2,2)),'r',1:1:size(data2,2),dataout2(1:1:size(data2,2)))
xlabel('��������'); ylabel('��ֵ');
legend('�˲�ǰ������' , '�˲��������');


figure;
subplot(211);
plot(data3(1,:));
title('����·�ź�');
xlabel('��������'); ylabel('��ֵ');
axis([0,500000, -4e4, 4e4]);
subplot(212);
plot(data3(2,:));
xlabel('��������'); ylabel('VAD');
axis([0,500000, -1, 2]); 

%��ͼ�Ƚ�
figure;
plot(1:1:size(data3,2),data3(1,1:1:size(data3,2)),'r',1:1:size(data3,2),dataout3(1:1:size(data3,2)))
xlabel('��������'); ylabel('��ֵ');
legend('�˲�ǰ������' , '�˲��������');

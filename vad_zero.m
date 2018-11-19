%% 姓名: 谭德志
%% 学号：18215363
function [vad_detected, vad_now]= vad_zero(audio)

    % 输入带标记信号，输出当前帧判断出当前帧的预期VAD和输出的VAD 
    % @param
    % audio: 2行 N*(r+1) 列
    % @output
    % vad_detected:当前帧的计算出来的VAD  0:非语音 1:语音
    % vad_now:用于计算当前的滤波器和响度计算  0:非语音 1:语音

    vad_detected = 1;
    vad_now = 1;
    
    signal = double(audio(1,:))/32768;  % 输入的信号并归一化

    t_e=0.8; % STE的门限
    t_z=150; % 过零率门限

    ste = sum(signal.^2);
    zcc=sum(signal(1:end-1).*signal(2:end)<0);

    vad_detected=(ste>t_e).*(zcc<t_z);
    vad_now = vad_detected;
end
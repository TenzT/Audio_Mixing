%% 姓名: 谭德志 
%% 学号: 18215363
function [vad_detected, vad_now]= vad(audio)

  % 输入带标记信号，输出当前帧判断出当前帧的预期VAD和输出的VAD 
  % @param
  % audio: 2行 N*(r+1) 列
  % @output
  % vad_detected:当前帧的计算出来的VAD  0:非语音 1:语音
  % vad_now:根据前5帧判断出来的VAD, 用于计算当前的滤波器和响度计算  0:非语音 1:语音
  
  
  r = 100;  % 往前追溯100帧
  N = 2048; % 一帧的抽样数
  
  vad_detected = 1;
  vad_now = 1;
  
  signal = audio(1,:);  % 输入的信号
  vad_before = audio(2,:);
  vad_before = vad_before(1:10:end); % 提取出当前的VAD
  
  % 根据前5帧的VAD输出的推算当前帧输出的VAD
  if(sum(vad_before(end-5:end-1)))==0
    vad_now = 0;
  end
    
  % 依据门限判断本帧的VAD值
  signal = reshape(signal, N, r+1);
  power = sum(signal.^2)./N; 
  power_min = min(power);

  if(log10(power(end)/16384^2)>=log10(150*power_min/16384^2))
    vad_detected = 1;
  elseif (log10(power(end)/16384^2)<=-4)
    vad_detected = 0;
  else
    signal = signal(:,end)'; 
    rxx = autocorr_my(signal, N); % 计算自相关序列
    rxx = rxx./rxx(1);            % 对第一个值进行归一化
    rxx_max = max(rxx);
    if (rxx_max<0.2)
      vad_detected = 0;
  end
end
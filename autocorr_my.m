%% Author: 谭德志 <tandezhi@master.local>
%% Created: 2018-11-13
function [rxx]= autocorr_my(signal, N)

  % 计算一帧的自相关序列 
  % @param
  % signal: 输入的帧
  % @output
  % rxx:自相关序列
  rxx = zeros(1, N/2-100);
  for m = 100:N/2-1
    signal_temp = int16(zeros(1,size(signal,2)));
    signal_temp(1:end-m) = signal(m+1:end);
    signal_temp = signal_temp .* signal;
    rxx(m-99) = sum(signal_temp(1:N/2));
  end

end

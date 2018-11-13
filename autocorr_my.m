%% Author: 谭德志 <tandezhi@master.local>
%% Created: 2018-11-13
function [rxx]= autocorr_my(frame, N)

  % 计算一帧的自相关序列 
  % @param
  % frame: 输入的帧
  % @output
  % rxx:自相关序列
  rxx = zeros(1, N/2-100)
  for m = 100:N/2-1
    frame_temp = zeros(1,size(frame,2))
  end

endfunction

function [dataout] = filter_time_variant(datain,VAD)
%这里要利用filtic函数 为滤波器的直接II型实现选择初始条件
%求解查分方程 f(i) - by(i-1)=(1-b)x(i)
%写出状态方程H（Z）得到分子分母上的系数
%y(-1) = 0 y(-2) = 1 ，x(-1) = 1 x(-2） = 2
% x 为滤波前序列 y 为输出 序列
% 总结一下 首先把num（分子上的系数） 和den（分母上的系数） 写出来
%——————————————————————
%          初始参数设置
%——————————————————————
bmax=0.956;
%N1表示时变滤波器系数b从0.956变化至0.18时的采样点数
N1=960;
bmin=0.18;
%N2表示时变滤波器系数b从0.18变化至0.956时的采样点数
N2=96000;
%——————————————————————
%    根据输入信号的VAD值设置滤波器
%——————————————————————
if VAD==1
    %VAD=1  检测到信号时
    b1=bmin+(0.18-0.956)/N1;
    if b1<0.18
        b1=0.18;
    end
    num = [1-b1];
    den = [1 -b1];    
else
    %VAD=0   无检测到信号时
    b2=bmax+(0.956-0.18)/N2;
     if b2>0.956
        b1=0.956;
    end
    num = [1-b2];
    den = [1 -b2] ;
end
%——————————————————————
%             滤波
%——————————————————————
% 滤波器初始条件
datain0 = 0;
dataout0= 0;
%生成初始条件
Zi = filtic(num, den , dataout0 , datain0);
%通过滤波器
if VAD==1
    [dataout , Zf] = filter(num , den ,datain, Zi);
else
    %用fdatool生成一个符合论文要求的滤波器filter_with_fdatool进行验证了
    %Hd=filter_with_fdatool;
    %dataout= filter(Hd,datain);
    [dataout , Zf] = filter(num , den ,datain, Zi);
end
%——————————————————————
%     观察滤波器的幅频响应
%——————————————————————
%画图
%figure(1)
%plot(n , datain ,'R-', n, dataout, 'b--');
%xlabel('n'); ylabel('(n)--y(n)');
%legend('Input data' , 'Output data', 1);
%grid;
%滤波器幅频特性，b=0.18=b0或者b=b1
%figure(2)
%[H,w]=freqz(num,den,2048)
%Hf=abs(H);
%Hx=angle(H);
%clf
%plot(w,Hf)


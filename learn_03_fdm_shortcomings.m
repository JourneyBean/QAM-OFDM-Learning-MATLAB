% 研究FDM下载波之间信道间干扰

% 正弦波参数
fs1 = 30;                   % 信号频率为30Hz
fc1 = 100;                  % 载波1频率为100Hz
fc2 = 110;                  % 载波2频率为110Hz
fc3 = 120;                  % 载波3频率为120Hz
fc4 = 130;                  % 载波4频率为130Hz
Fs = 10000;                 % 采样率10000Hz
t1 = 0; t2 = 0.1;           % 仿真时间0-0.1s

t = t1:1/Fs:t2-1/Fs;

% 信号
s1 = sin( 2*pi*fs1*t );

% 载波
c1 = sin( 2*pi*fc1*t );
c2 = sin( 2*pi*fc2*t );
c3 = sin( 2*pi*fc3*t );
c4 = sin( 2*pi*fc4*t );

% 生成信道信号
a1 = s1.*c1 + s1.*c2;
a2 = s1.*c1 + s1.*c3;
a3 = s1.*c1 + s1.*c4;

% 解调
y11 = a1.*c1, y12 = a1.*c2;
y21 = a2.*c1, y22 = a2.*c3;
y31 = a3.*c1, y32 = a3.*c4;

% 输出结果
figure(1);
subplot(3,3,1),plot(s1),title('原始信号30Hz');
subplot(3,3,2),plot(y11),title('信道1 100Hz载波解调信号');
subplot(3,3,3),plot(y12),title('信道1 110Hz载波解调信号');
subplot(3,3,5),plot(y21),title('信道2 100Hz载波解调信号');
subplot(3,3,6),plot(y22),title('信道2 120Hz载波解调信号');
subplot(3,3,8),plot(y31),title('信道3 100Hz载波解调信号');
subplot(3,3,9),plot(y32),title('信道3 130Hz载波解调信号');

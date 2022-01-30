% 学习正交正弦波，不同频率正弦波正交，使用同步检波检出

% 正弦波参数
fs1 = 10;                   % 信号频率为20Hz
fs2 = 20;
fc1 = 100;                  % 载波1频率为100Hz
fc2 = 150;                  % 载波2频率为150Hz
Fs = 1000;                  % 采样率1000Hz
t1 = 0; t2 = 0.2;           % 仿真时间0-0.2s

t = t1:1/Fs:t2-1/Fs;

% 正弦波信号
s1 = sin( 2*pi*fs1*t );
s2 = sin( 2*pi*fs2*t );

% 载波
c1 = sin( 2*pi*fc1*t );
c2 = sin( 2*pi*fc2*t );

% 调制、混叠
s = s1.*c1 + s2.*c2;

% 解调载波1信号
y1 = s.*c1;
% 解调摘波2信号
y2 = s.*c2;

% 输出结果
figure(1);
subplot(2,3,1),plot(s1),title('原始信号1');
subplot(2,3,4),plot(s2),title('原始信号2');
subplot(2,3,2),plot(s),title('载波信号');
subplot(2,3,3),plot(y1),title('解调信号1');
subplot(2,3,6),plot(y2),title('解调信号2');
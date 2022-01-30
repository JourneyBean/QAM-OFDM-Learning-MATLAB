% 同步调制解调实验

Fs = 1000;          % 采样频率
fs = 10;            % 正弦信号频率
fc = 100;           % 载波频率
t1 = 0, t2 = 1;     % 仿真时间

t = t1:1/Fs:t2-1/Fs;

% 正弦信号
s1 = sin( 2*pi*fs*t );
% 载波
s2 = sin( 2*pi*fc*t );

% 调制
s = s1 .* s2;

% 解调
s3 = s .* s2;

% 输出
figure(1);
subplot(1,3,1),plot(s1),title('原始信号');
subplot(1,3,2),plot(s), title('调制信号');
subplot(1,3,3),plot(s3),title('解调信号');
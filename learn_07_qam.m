% 研究16QAM调制与解调

Fs = 1000;          % 采样率1000Hz
fc = 40;            % 载波频率40Hz
t1 = 0; t2 = 0.5;   % 仿真时间0-0.2s

data = [0 1 0 1 1 1 1 0 0 0 1 0 0 1 1 0 1 1];  % 待调制数据
baud = 40;          % 波特率40bps

t = t1:1/Fs:t2-1/Fs;
baud_iq = baud/4;   % 一次传输4位，实际波特率10bps


%%%%% 调制 %%%%%

% 原数据补零
data = [data, zeros(1, 4-mod(length(data),4) )];

% 生成IQ通道数据
iq_syms = [+3 +1 -3 -1];      % IQ映射表，对应00 01 10 11

i_send_data = zeros(1,length(data)/4);
q_send_data = zeros(1,length(data)/4);

for i=1:4:length(data)
    i_send_data(ceil(i/4)) = iq_syms( data( i )*2+data(i+1)+1 );  % 转十进制来索引映射
    q_send_data(ceil(i/4)) = iq_syms( data(i+2)*2+data(i+3)+1 );
end

% 生成IQ通道采样信号
i_send_signal = zeros(1,length(t));
q_send_signal = zeros(1,length(t));

for i=1:1:length(t)
    i_send_signal(i) = i_send_data( ceil(i/(Fs/baud_iq)) );
    q_send_signal(i) = q_send_data( ceil(i/(Fs/baud_iq)) );
end

% 调制，叠加
ci = cos( 2*pi*fc*t );
cq = sin( 2*pi*fc*t );
i_send_carry = ci.*i_send_signal;
q_send_carry = -cq.*q_send_signal;
carry = 1/sqrt(10)*(i_send_carry+q_send_carry);


%%%%% 解调 %%%%%

% 同步解调
i_recv_carry = ci.*carry;
q_recv_carry = -cq.*carry;

% 积分
sum_i = 0;
sum_q = 0;
i_recv_int = zeros(1,length(t));
q_recv_int = zeros(1,length(t));
for i = 1:length(t)
    sum_i = sum_i + i_recv_carry(i);
    sum_q = sum_q + q_recv_carry(i);
    i_recv_int(i) = sum_i;
    q_recv_int(i) = sum_q;
    if ( mod(i,Fs/baud_iq)==0 )     % 接收每个码元后归零
        sum_i = 0;
        sum_q = 0;
    end
end

% 抽样判决，IQ解码
% 注意这里并没有特意设计，实际中要判断好最佳抽样点和最佳门限
i_temp = 0;
q_temp = 0;

decoded = zeros(1,length(data));        % 解码数据
p_decoded = 1;

for i=1:length(t)
    % 在码元末尾处判决
    if ( mod(i,Fs/baud_iq)==Fs/baud_iq-2 )
        
        % 判决
        if ( i_recv_int(i)>40 )
            i_temp = 3;
        else
            if ( i_recv_int(i)>10 )
                i_temp = 1;
            else
                if ( i_recv_int(i)<-40 )
                    i_temp = -3;
                else
                    i_temp = -1;
                end
            end
        end
        
        if ( q_recv_int(i)>40 )
            q_temp = 3;
        else
            if ( q_recv_int(i)>10 )
                q_temp = 1;
            else
                if ( q_recv_int(i)<-40 )
                    q_temp = -3;
                else
                    q_temp = -1;
                end
            end
        end
        
        % 解码
        switch(i_temp)
            case 3
                decoded(p_decoded:p_decoded+1)=[0 0];
            case 1
                decoded(p_decoded:p_decoded+1)=[0 1];
            case -3
                decoded(p_decoded:p_decoded+1)=[1 0];
            case -1
                decoded(p_decoded:p_decoded+1)=[1 1];
        end
        
        switch(q_temp)
            case 3
                decoded(p_decoded+2:p_decoded+3)=[0 0];
            case 1
                decoded(p_decoded+2:p_decoded+3)=[0 1];
            case -3
                decoded(p_decoded+2:p_decoded+3)=[1 0];
            case -1
                decoded(p_decoded+2:p_decoded+3)=[1 1];
        end
        p_decoded = p_decoded+4;
        
    end
end


% 绘制
figure(1),
subplot(7,2,1),stem(data),title('原始数据');
subplot(7,2,3),stem(i_send_data),title('I通道数据');
subplot(7,2,4),stem(q_send_data),title('Q通道数据');
subplot(7,2,5),plot(i_send_carry),title('I通道载波');
subplot(7,2,6),plot(q_send_carry),title('Q通道载波');
subplot(7,2,7),plot(carry),title('载波');
subplot(7,2,9),plot(i_recv_carry),title('I检波载波');
subplot(7,2,10),plot(q_recv_carry),title('Q检波载波');
subplot(7,2,11),plot(i_recv_int),title('I检波积分');
subplot(7,2,12),plot(q_recv_int),title('Q检波积分');
subplot(7,2,13),stem(decoded),title('解码数据');


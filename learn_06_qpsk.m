% 研究QPSK调制与解调

Fs = 1000;          % 采样率1000Hz
fs = 40;            % 信号频率40Hz
t1 = 0; t2 = 0.45;   % 仿真时间0-0.45s

baud = 20;          % 波特率20bps
codes = [0 1 0 1 0 0 1 0 1]; % 原始信息

t = t1:1/Fs:t2-1/Fs;
baud_iq = baud/2;

i_codes = zeros(1, ceil(length(codes)/2));
q_codes = zeros(1, ceil(length(codes)/2));
bin_signal = zeros(1, length(t));
i_signal = zeros(1, length(t));
q_signal = zeros(1, length(t));

% 生成数字信号序列（仅作展示）
for i = 1:length(t)
    bin_signal(i) = codes( floor(t(i)*baud)+1 );
end

% 生成IQ序列
for i = 1:2:length(codes)
    
    % 如果不足1组，补零
    if (i>length(codes)-1)
        codes(length(codes)+1) = 0;
    end
    
    % 硬编码实现格雷码
    if ( codes(i)==0 && codes(i+1)==0 )
        i_codes(ceil(i/2)) = 1;
        q_codes(ceil(i/2)) = 1;
    else
        if ( codes(i)==0 && codes(i+1)==1 )
            i_codes(ceil(i/2)) = -1;
            q_codes(ceil(i/2)) = 1;
        else
            if ( codes(i)==1 && codes(i+1)==1 )
                i_codes(ceil(i/2)) = -1;
                q_codes(ceil(i/2)) = -1;
            else
                i_codes(ceil(i/2)) = 1;
                q_codes(ceil(i/2)) = -1;
            end
        end
    end
end

% 生成IQ信号序列
for i = 1:length(t)
    i_signal(i) = i_codes( floor(t(i).*baud_iq)+1 );
    q_signal(i) = q_codes( floor(t(i).*baud_iq)+1 );
end

% QPSK调制
c1 = cos( 2*pi*fs*t );
c2 = sin( 2*pi*fs*t );
t1 = i_signal.*c1;
t2 = q_signal.*c2;

ta = 1/sqrt(2)*(t1-t2);             % 天线发送，假设理想传输

% QPSK解调

% 同步解调
r1 = c1.*ta;
r2 = -c2.*ta;

% 积分
sum_i = 0;
sum_q = 0;
ri = zeros(1, length(t));           % i,q通道积分数据
rq = zeros(1, length(t));
for i = 1:length(t)
    sum_i = sum_i + r1(i);
    sum_q = sum_q + r2(i);
    ri(i) = sum_i;
    rq(i) = sum_q;
    if ( mod(i,Fs/baud_iq)==0 )     % 接收每个码元后归零
        sum_i = 0;
        sum_q = 0;
    end
end

% 模拟判决（反面例子）
%   注意！这里直接通过积分值判决，但实际情况不能这么用，
% 因为如果信道不理想，两个通道值可能不能同时跳变，形成毛刺，
% 实际情况中应该使用统一的时钟来抽样判决。
% last_i = 0;
% last_q = 0;
% ji = zeros(1, length(t));
% jq = zeros(1, length(t));
% for i = 1:length(t)
%     ji(i) = last_i;
%     jq(i) = last_q;
%     if ( ri(i)>10 )
%         last_i = 1;
%     else
%         if ( ri(i)<-10 )
%             last_i = 0;
%         end
%     end
%     
%     if ( rq(i)>10 )
%         last_q = 1;
%     else
%         if ( rq(i)<-10 )
%             last_q = 0;
%         end
%     end
% end

% 模拟IQ通道抽样时钟
decoded = zeros(1,length(codes));
p_decoded = 1;
for i=1:length(t)
    % 码元中点
    if ( mod(i,Fs/baud_iq)==Fs/baud_iq/2 )
        
        % 判决，解格雷码，输出结果
        if( ri(i)>0 && rq(i)>0 )
            decoded(p_decoded) = 0;
            decoded(p_decoded+1) = 0;
        else
            if( ri(i)<0 && rq(i)>0 )
                decoded(p_decoded) = 0;
                decoded(p_decoded+1) = 1;
            else
                if( ri(i)<0 && rq(i)<0 )
                    decoded(p_decoded) = 1;
                    decoded(p_decoded+1) = 1;
                else
                    decoded(p_decoded) = 1;
                    decoded(p_decoded+1) = 0;
                end
            end
        end
        p_decoded = p_decoded + 2;
        
    end
end

% 绘图
figure(1),
subplot(7,2,1),stem(codes),title('输入');
subplot(7,2,3),plot(i_signal),title('I路信号');
subplot(7,2,4),plot(q_signal),title('Q路信号');
subplot(7,2,5),plot(ta),title('载波');
subplot(7,2,7),plot(r1),title('解调I');
subplot(7,2,8),plot(r2),title('解调Q');
subplot(7,2,9),plot(ri),title('积分I');
subplot(7,2,10),plot(rq),title('积分Q');
subplot(7,2,11),plot(ji),title('判决I');
subplot(7,2,12),plot(jq),title('判决Q');
subplot(7,2,13),stem(decoded),title('输出');

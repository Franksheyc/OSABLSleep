function [FF,CFF]=datanormalization(C3,C4,C3t,C4t,EOG,EMG)

EOG=EOG(:,[1:32 33 34 36 37]);
%%%%%%%%%%%%%%用于结果统计
% [C3,C4,EOG,EMG]=data_norms(C3,C4,EOG,EMG);%尝试对每类特征进行归一化，结果只有35%
no_re=0;%[8]; %means stds ku sk eng pe zerocrossing median fra
no_co=0;%[3];%mean std median eng ratio_sw ratio_al ratio_sp ratio_be
no_m=0;%[1 7 8 9];
no_o=0;%[1 5 7 8 9];
noneed=[0];%sw delta theta alpha spindle beta
% [C31,C41,EOG1,EMG1,C3s,C4s,EOGs,EMGs,fre_rank]=feature_node_stlection(C3,C4,EOG,EMG,no_re,no_co,no_m,no_o,noneed);

cm=length(C4);
% % fe=othersignal(da);%可计算30s内的心率，心率变化，血氧，呼吸的强弱等  由于信号长度不统一，故需要重新规划，提前提取特征
C40=C4(:,[1:26 63:end]);
C30=C3(:,[1:26 63:end]);
C41=[C4(:,27:32) C4(:,38:42).*(rand(cm,1)/10+0.9) C4(:,48:52).*(rand(cm,1)/10+0.9) C4(:,53:57).*(rand(cm,1)/10+0.9) C4(:,58:62).*(rand(cm,1)/10+0.9)];
C31=[C3(:,27:32) C3(:,38:42).*(rand(cm,1)/10+0.9) C3(:,48:52).*(rand(cm,1)/10+0.9) C3(:,53:57).*(rand(cm,1)/10+0.9) C3(:,58:62).*(rand(cm,1)/10+0.9)];

[C32,C42,EOG2,EMG2]=feature_enhance(C3,C4,EOG,EMG);

C40=zscore(C40')';
EMG=zscore(EMG')';
EOG=zscore(EOG')';
C42=zscore(C42')';
EMG2=zscore(EMG2')';
EOG2=zscore(EOG2')';
C3t=zscore(C3t')';
C4t=zscore(C4t')';



[C11,C12,M,CM1,CM2,C21,C22]=feature_en(C3,C4,C3t,C4t,EMG,C32,C42,EMG2);

C1=(C11+C12)/2;
CM1=(CM1+CM2)/2;
C2=(C21+C22)/2;

C40=(C30+C40)/2;
C41=(C31+C41)/2;
C42=(C32+C42)/2;
C4t=(C3t+C4t)/2;

EOG1=(EOG(:,1:16)+EOG(:,17:32))/2;
% FF=[C40 C41 C42 C4t EOG1];
FF=[C40 C41 C42 C4t EOG1 EMG];% EOG EOG2 EMG2]; %Hjorth_mobility Hjorth_compelicity];
CFF=[C1 C2 M CM];%3 3 3 18
end

function [C11,C12,M,CM1,CM2,C21,C22]=feature_en(C3,C4,C3t,C4t,EMG,C32,C42,EMG2)
   

C11=bilif(C3t,C3t,[1 2  6],2);
C12=bilif(C4t,C4t,[1 2  6],2);
M=bilif(EMG,EMG,[1 2  6],1);
CM1=bilif(C32(:,27:end),EMG2(:,27:end),[1 2  6],3);
CM2=bilif(C42(:,27:end),EMG2(:,27:end),[1 2  6],3);

% C31=C3(:,1:50);
C32=C3(:,51:end);
% C41=C4(:,1:50);
C42=C4(:,51:end);
C21=bilif(C32,C32,[1:6 7:12 37:42],3);
C22=bilif(C42,C42,[1:6 7:12 37:42],3);

% EMG3(:,1)=[EMG(:,1);EMG(end,1)]./[EMG(1,5);EMG(:,5)];
% EMG3(:,2)=[EMG(:,16);EMG(end,16)]./[EMG(1,20);EMG(:,20)];
% 
% C43(:,1)=[C4(:,51);C4(end,51)]./[C4(1,55);C4(:,55)];
% C43(:,2)=[C4(:,69);C4(end,69)]./[C4(1,74);C4(:,74)];
% C43=C43(1:end-1,:);EMG3=EMG3(1:end-1,:);
% C43=mapminmax(C43')';EMG3=mapminmax(EMG3')';
end
%用C42与EMG求比值（能量，开方）
function E=bilif(sig1,sig2,s,mode)
if mode==1
    n=4;%emg/emg
elseif mode==2
    n=5;%eeg/eeg
else
    n=0;%eeg/emg
end
for i=1:length(s)
    h=(s(i)-1)*(n+1)+1;%特征起始位置
    h1=h+n;
    E(:,i)=[sig1(:,h);sig1(end,h)]./[sig2(1,h1);sig2(:,h1)];
end
E=E(1:end-1,:);
E=zscore(E);
end
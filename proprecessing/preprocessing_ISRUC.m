clear;
clc;
tic
% objDir='F:\sleep\data\small database';
% objDir02='F:\sleep\data';
% outputDir ='F:\sleep\data\';
% outputDir1 = 'E:\sleep\MASS\mass original\label\SS';

objDir1='D:\database\data\ISRUC\2';
objDir2='D:\database\data\ISRUC\2';
outputDir ='D:\database\data\ISRUC\extracted\2\data';
outputdir1='D:\database\data\ISRUC\extracted\2\label';
outputdir2='D:\database\data\ISRUC\extracted\2\otherdata';
mkdir(outputDir)
mkdir(outputdir1)
mkdir(outputdir2)
% outputDir1 = 'E:\sleep\MASS\mass original\label\SS';

% outputDir1 = 'D:\database\MASS\STFT\SS';
%%%滤波器设计
resamplerate=125;
fx00=0.3;%EEG EOG的下沿
fx1=35;
fx2=35;
fx01=10;%EMG下
fx3=resamplerate/2-2;%EMG上
hd=100;
n=50;

% n=dir(objDir1);
%     fx11=2*fx1/hd;
%     fx22=2*fx2/hd;
%     fx33=2*fx3/hd;
%     fx44=2*fx4/hd;
%     window1=hamming(n+1);
%     b1=fir1(n,[fx11 fx22],window1);
%     b2=fir1(n,[fx11 fx33],window1);
%     b3=fir1(n,[fx11 fx44],window1);
[BT_eeg_B,BT_eeg_A]=filterdesign(fx00,fx1,resamplerate);%设计巴特沃斯滤波器参数
[BT_eog_B,BT_eog_A]=filterdesign(fx00,fx2,resamplerate);%设计巴特沃斯滤波器参数
[BT_emg_B,BT_emg_A]=filterdesign(fx01,fx3,resamplerate);%设计巴特沃斯滤波器参数

%%%stft参数
windows=hamming(128);
nooverlap=38;
nfft=128;

% for ii=41:length(n)-2
%     na0=n(ii+2).name;
%     path=[objDir1,'\',na0,'\polysomnography\edfs'];
%     path1=[objDir2,'\',na0,'\label'];
    % %     bgfile1 = [objDir,num2str(p(ii)),'\start_time.mat'];
    % %     load(bgfile1);
    N1=dir(objDir1);
    N2=dir(objDir2);
    for sub=1:length(N2)-3% mros 475有问题
        na=N1(sub+2).name;
        nb=N2(sub+2).name;
%         bgfile1=[objDir1,'\',na,'\',na,'.rec'];
%         bgfile2=[objDir2,'\',nb,'\',nb,'_1.txt'];
%         bgfile3=[objDir2,'\',nb,'\',nb,'_2.txt'];
        bgfile1=[objDir1,'\',na,'\2\2.rec'];
        bgfile2=[objDir2,'\',nb,'\2\2_1.txt'];
        bgfile3=[objDir2,'\',nb,'\2\2_2.txt'];
        %%%%%%读源文件    注意，需要使两段数量相等
        head=edfread(bgfile1);re=[];
        if isempty(find(strcmp(head.label,'A1')==1)) && isempty(find(strcmp(head.label,'M1')==1))

            if ~isempty(find(strcmp(head.label,'C3A2')==1))
                tc(1)=find(strcmp(head.label,'C3A2')==1);
            else
                tc(1)=find(strcmp(head.label,'C3M2')==1);
            end
            if ~isempty(find(strcmp(head.label,'C4A1')==1))
                tc(2)=find(strcmp(head.label,'C4A1')==1);
            else
                tc(2)=find(strcmp(head.label,'C4M1')==1);
            end
            if ~isempty(find(strcmp(head.label,'LOCA2')==1))
                tc(3)=find(strcmp(head.label,'LOCA2')==1);
            else
                tc(3)=find(strcmp(head.label,'E1M2')==1);
            end
            if ~isempty(find(strcmp(head.label,'ROCA1')==1))
                tc(4)=find(strcmp(head.label,'ROCA1')==1);
            else
                tc(4)=find(strcmp(head.label,'E2M1')==1);
            end
        else
            if ~isempty(find(strcmp(head.label,'A2')==1))
                re(1)=find(strcmp(head.label,'A2')==1);
                re(2)=find(strcmp(head.label,'A1')==1);
            else
                re(1)=find(strcmp(head.label,'M2')==1);
                re(2)=find(strcmp(head.label,'M1')==1);
            end
            tc(1)=find(strcmp(head.label,'C3')==1);
            tc(2)=find(strcmp(head.label,'C4')==1);
            if ~isempty(find(strcmp(head.label,'LOC')==1))
            tc(3)=find(strcmp(head.label,'LOC')==1);
            tc(4)=find(strcmp(head.label,'ROC')==1);
            else
            tc(3)=find(strcmp(head.label,'E1')==1);
            tc(4)=find(strcmp(head.label,'E2')==1);
            end
        end
        
        if ~isempty(find(strcmp(head.label,'X1')==1))
            tc(5)=find(strcmp(head.label,'X1')==1);
        else
            tc(5)=find(strcmp(head.label,'24')==1);
        end
        if ~isempty(find(strcmp(head.label,'X2')==1))
            tc(6)=find(strcmp(head.label,'X2')==1);
        else
            tc(6)=find(strcmp(head.label,'25')==1);
        end
%         tc(7)=find(strcmp(head.label,'X3')==1);
        if ~isempty(find(strcmp(head.label,'SaO2')==1))
            tc(7)=find(strcmp(head.label,'SaO2')==1);
        else
            tc(7)=find(strcmp(head.label,'SpO2')==1);
        end
        
        [~,data]=edfread(bgfile1,'targetSignals',tc);
        eeg=data(1:2,:);
        eog=data(3:4,:);
        emg=data(5,:);
        ecg=data(6,:);

        if ~isempty(re)
eeg(1,:)=eeg(1,:)-data(re(1),:);
eeg(2,:)=eeg(2,:)-data(re(2),:);
eog(1,:)=eog(1,:)-data(re(1),:);
eog(2,:)=eog(2,:)-data(re(2),:);
        end
%         limb1=data(7,:);
%         limb2=data(8,:);
        spo2=data(7,:);
        sample=head.samples(tc(1:5))/2;
        rate=head.samples(tc(6:7))/2;
%         switch na0
%             case 'ccshs'
%                 %通常的，第一个为通用名称（C3），第二个为特定名称（C3M2）
%                 res1={'A2'};
%                 res2={'A1'};
%                 EEG1={'C3'};
%                 EEG1t={'C3A2'};
%                 EEG2={'C4'};
%                 EEG2t={'C4A1'};
%                 EOG1={'LOC'};
%                 EOG1t={'LOCA1','LOCA2'};
%                 EOG2={'ROC'};
%                 EOG2t={'ROCA1','ROCA2'};
%                 EMG1={'EMG1'};
%                 EMGt1={'EMG1-EMG2'};
%                 EMG2={'EMG2'};
%                 EMGt2={'EMG1-EMG2'};
%                 [eeg,eog,emg,sample]=labelpos(data,head,res1,res2,EEG1,EEG1t,EEG2,EEG2t,EOG1,EOG1t,EOG2,EOG2t,EMG1,EMGt1,EMG2,EMGt2);
%             case 'cfs'
%                 res1={'M2'};
%                 res2={'M1'};
%                 EEG1={'C3'};
%                 EEG1t={'C3M2'};
%                 EEG2={'C4'};
%                 EEG2t={'C4M1'};
%                 EOG1={'LOC'};
%                 EOG1t={'LOCM1','LOCM2'};
%                 EOG2={'ROC'};
%                 EOG2t={'ROCM1','ROCM2'};
%                 EMG1={'EMG1'};
%                 EMGt1={'EMG1-EMG2'};
%                 EMG2={'EMG2'};
%                 EMGt2={'EMG1-EMG2'};
%                 [eeg,eog,emg,sample]=labelpos(data,head,res1,res2,EEG1,EEG1t,EEG2,EEG2t,EOG1,EOG1t,EOG2,EOG2t,EMG1,EMGt1,EMG2,EMGt2);
%             case 'sof'
%                 res1={'A2'};
%                 res2={'A1'};
%                 EEG1={'C3'};
%                 EEG1t={'C3A2'};
%                 EEG2={'C4'};
%                 EEG2t={'C4A1'};
%                 EOG1={'LOC'};
%                 EOG1t={'LOCA1','LOCA2'};
%                 EOG2={'ROC'};
%                 EOG2t={'ROCA1','ROCA2'};
%                 EMG1={'LChin' 'EMGL'};
%                 EMGt1={'LChin-RChin' 'EMGL-EMGR'};
%                 EMG2={'RChin' 'EMGR'};
%                 EMGt2={'LChin-RChin' 'EMGL-EMGR'};
%                 [eeg,eog,emg,sample]=labelpos(data,head,res1,res2,EEG1,EEG1t,EEG2,EEG2t,EOG1,EOG1t,EOG2,EOG2t,EMG1,EMGt1,EMG2,EMGt2);
%         end
%%%%%%%%%%%%%%%%%   homepap
% res1={'M2' 'A2'};
% res2={'M1' 'A1'};
% EEG1={'C3'};
% EEG1t={'C3M2' 'C3A2'};
% EEG2={'C4'};
% EEG2t={'C4M1' 'C4A1'};
% EOG1={'E1' 'LOC' 'LEOG' 'EOGL'};
% EOG1t={'E1M1','E1M2' 'E1E2'};
% EOG2={'E2' 'ROC' 'REOG' 'EOGR'};
% EOG2t={'E2M1','E2M2'};
% EMG1={'Lchin' 'LCHIN' 'LChin' 'Chin' 'CHIN' 'ChinEMG' 'Chin1Chin2' 'Chin1' 'LchinCchin' 'EMG1' 'L'};
% EMGt1={'LChin-RChin' 'EMGL-EMGR' 'LChin-RChin' 'LChin-RChin' 'LChin-RChin' 'EMG1-EMG2'};
% EMG2={'Rchin' 'RCHIN' 'RChin'  'Chin' 'CHIN' 'ChinEMG' 'Chin1Chin2' 'Chin2' 'EMG2' 'R'};
% EMGt2={'LChin-RChin' 'EMGL-EMGR' 'LChin-RChin' 'LChin-RChin' 'LChin-RChin' 'EMG1-EMG2'};
% [eeg,eog,emg,sample]=labelpos(data,head,res1,res2,EEG1,EEG1t,EEG2,EEG2t,EOG1,EOG1t,EOG2,EOG2t,EMG1,EMGt1,EMG2,EMGt2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%mesa
% res1={'A2'};
% res2={'A1'};
% EEG1={'EEG1'};
% EEG1t={'EEG1'};
% EEG2={'EEG2'};
% EEG2t={'EEG2'};
% EOG1={'EOGL'};
% EOG1t={'E1M1','E1M2'};
% EOG2={'EOGR'};
% EOG2t={'E2M1','E2M2'};
% EMG1={'EMG'};
% EMGt1={ 'EMG1-EMG2'};
% EMG2={'EMG'};
% EMGt2={'EMG1-EMG2'};
% [eeg,eog,emg,sample]=labelpos(data,head,res1,res2,EEG1,EEG1t,EEG2,EEG2t,EOG1,EOG1t,EOG2,EOG2t,EMG1,EMGt1,EMG2,EMGt2);
% %%%%%%%%%%%%%%%%
%%%%%%mros
% res1={'A2'};
% res2={'A1'};
% EEG1={'C3'};
% EEG1t={'C3A2'};
% EEG2={'C4'};
% EEG2t={'C4A1'};
% EOG1={'LOC'};
% EOG1t={'LOCA1','LOCA2'};
% EOG2={'ROC'};
% EOG2t={'ROCA1','ROCA2'};
% EMG1={'LChin'};
% EMGt1={ 'EMG1-EMG2'};
% EMG2={'RChin'};
% EMGt2={'EMG1-EMG2'};
% [eeg,eog,emg,sample]=labelpos(data,head,res1,res2,EEG1,EEG1t,EEG2,EEG2t,EOG1,EOG1t,EOG2,EOG2t,EMG1,EMGt1,EMG2,EMGt2);


%%%%%%%%%%%%%%%%
        %%%%%%%%%mass%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%E2
        % %     [label,data]=edfread(bgfile1);
        % %     if p(ii)==1 || p(ii)==3 || p(ii)==5
        % %       try
        % %           position1(1)=find(strcmp(label.label, 'F4M1'));
        % %           position1(2)=find(strcmp(label.label, 'C4M1'));
        % %           position1(3)=find(strcmp(label.label, 'O2M1'));
        % %           position1(4)=find(strcmp(label.label, 'F3M2'));
        % %           position1(5)=find(strcmp(label.label, 'C3M2'));
        % %           position1(6)=find(strcmp(label.label, 'O1M2'));
        % %           position1(7)=find(strcmp(label.label, 'E1M2'));
        % %           position1(8)=find(strcmp(label.label, 'E2M2'));
        % %           position1(9)=find(strcmp(label.label, 'Chin1Chin2'));
        % %        catch
        % %           position1(1)=find(strcmp(label.label, 'F4M2'));
        % %           position1(2)=find(strcmp(label.label, 'C4M2'));
        % %           position1(3)=find(strcmp(label.label, 'O2M2'));
        % %           position1(4)=find(strcmp(label.label, 'F3M1'));
        % %           position1(5)=find(strcmp(label.label, 'C3M1'));
        % %           position1(6)=find(strcmp(label.label, 'O1M1'));
        % %           position1(7)=find(strcmp(label.label, 'E1M1'));
        % %           position1(8)=find(strcmp(label.label, 'E2M1'));
        % %           position1(9)=find(strcmp(label.label, 'Chin1Chin2'));
        % %        end
        % %     else
        % %        try
        % %           position1(1)=find(strcmp(label.label, 'EEGC3CLE'));
        % %           position1(2)=find(strcmp(label.label, 'EEGC4CLE'));
        % %           position1(3)=find(strcmp(label.label, 'EOGLeftHoriz'));
        % %           position1(4)=find(strcmp(label.label, 'EOGRightHoriz'));
        % %           position1(5)=find(strcmp(label.label, 'EMGChin'));
        % %        catch
        % %           position1(1)=find(strcmp(label.label, 'EEGC3LER'));
        % %           position1(2)=find(strcmp(label.label, 'EEGC4LER'));
        % %           position1(3)=find(strcmp(label.label, 'EOGLeftHoriz'));
        % %           position1(4)=find(strcmp(label.label, 'EOGRightHoriz'));
        % %           position1(5)=find(strcmp(label.label, 'EMGChin'));
        % %       end
        % %     end
        %     data1=data(position1,:);
        % %     samples=label.samples;
        %     sample=label.samples(position1);%%采样率
        clear data
        
        %%%%%%%%%%
        label=textread(bgfile2);
        label1=textread(bgfile3);

        %     if ii==1 || ii==3
        ll=length(label);%ll=length(label)-1;
        epochtime=30*resamplerate;
        %     else
        %         ll=floor((length(label))*2/3);%ll=floor((length(label))*2/3);
        %         epochtime=30*resamplerate;
        %     end
        
        %     lab=importdata(bgFile1);
        %     %%%找出第一个标签的开始时间，是之与数据对应
        %     mark1=find(lab{2}==',',1);
        %     mark2=find(lab{end}==',',1);
        %     aa1=lab{2}(2:mark1-1);
        %     aa2=lab{end}(2:mark2-1);
        %     bb1=str2num(aa1);
        %     bb2=str2num(aa2);
        %     bb1=ceil(bb1*256);
        %     bb2=ceil(bb2*256);
        %     %%%
        %%%判断数组中是否有0，并取出非0元素
        ecg=ecg(:,1:ll*rate(1)*30);
        spo2=spo2(:,1:ll*rate(2)*30);
%         if rate(2)~=1
%             spo2=resample(spo2,1,rate(2));
%         end
        [data_EEG,ratee]=getno0data(eeg,[1 2],sample(1),ll);
        [data_EOG,rateo]=getno0data(eog,[1 2],sample(3),ll);
        [data_EMG,ratem]=getno0data(emg,1,sample(5),ll);
        sample(1)=ratee;sample(3)=rateo;sample(5)=ratem;
        %     data_EEG=getno0data(data1,n1,sample(1));
        %     data_EOG=getno0data(data1,n3,sample(2));
        %     data_EMG=getno0data(data1,n2,sample(3));
%         if length(position1)==7
%             data_EMG=(data_EMG(1,:)+data_EMG(2,:))-data_EMG(3,:);
%         end
        %%%%%从起点取有效信号   需先检查是否与开始不一致
%         data_EEG=data_EEG(:,first_point(sub)*sample(1)/256:end);
%         data_EOG=data_EOG(:,first_point(sub)*sample(3)/256:end);
%         data_EMG=data_EMG(:,first_point(sub)*sample(5)/256:end);
        
%         unit=20;
%         l=length(data_EEG)/resamplerate/unit;
%         if l<ll
%             ll=l;
%             label=label(1:l);
%         end
        %%%%%%信号整合
        data_EEG=resample(data_EEG',resamplerate,sample(1));
        data_EOG=resample(data_EOG',resamplerate,sample(3));
        data_EMG=resample(data_EMG,resamplerate,sample(5));
        data_EEG=data_EEG';
        data_EOG=data_EOG';
        %     for iii=1:4
        %         if sum(ismember(0,data_EEG(iii,:)))==0
        %            dat(iii,:)=resample(data_EEG(iii,:),resamplerate,sample(iii));
        %         else
        %            x=find(data_EEG(iii,:)==0, 1 );
        %            data0=data_EEG(iii,1:x-1);
        %            dat(iii,:)=resample(data0,resamplerate,sample(iii));
        %         end
        %         clear data0
        %     end
        %     data_EMG=resample(data_EMG,resamplerate,sample(5));
        clear data1
        
        for jj=1:ll
            dat01=data_EEG(1,(jj-1)*epochtime+1:jj*epochtime);%注意基线的位置    信号顺序为C3 C4 EOGL EOGR EMG
            dat011=data_EEG(2,(jj-1)*epochtime+1:jj*epochtime);
            dat02=data_EOG(1,(jj-1)*epochtime+1:jj*epochtime);
            dat021=data_EOG(2,(jj-1)*epochtime+1:jj*epochtime);
            dat03=data_EMG((jj-1)*epochtime+1:jj*epochtime);
            
            % %         phy1=mean(label.physicalMax(position1(1:2)));
            % %         phy2=mean(label.physicalMax(position1(3:4)));
            % %         if length(position1)==6
            % %             phy3=mean(label.physicalMax(position1(5:6)));
            % %         else
            % %             phy3=label.physicalMax(position1(5));
            % %         end
            % %            if mean(abs(dat01))<0.5*phy1 & mean(abs(dat02))<0.5*phy2 & mean(abs(dat03))<0.5*phy3
            DAT(jj,1:epochtime) = filtfilt( BT_eeg_B , BT_eeg_A , dat01' );
            DAT(jj,epochtime+1:epochtime*2) = filtfilt( BT_eeg_B , BT_eeg_A , dat011' );
            DAT(jj,epochtime*2+1:epochtime*3) = filtfilt( BT_eog_B , BT_eog_A , dat02' );
            DAT(jj,epochtime*3+1:epochtime*4) = filtfilt( BT_eog_B , BT_eog_A , dat021' );
            DAT(jj,epochtime*4+1:epochtime*5) = filtfilt( BT_emg_B , BT_emg_A , dat03' );
            
            %                DAT(jj,1:3000)= filter(b1,1,dat01);
            %                DAT(jj,3001:6000)= filter(b1,1,dat011);
            %                DAT(jj,6001:9000) = filter(b2,1,dat02);
            %                DAT(jj,9001:12000) = filter(b2,1,dat021);
            %                DAT(jj,12001:15000) = filter(b3,1,dat03);
            % %                clear dat01
            % %                clear dat011
            % %                clear dat02
            % %                claer dat021
            % %                clear dat03
            % %            else
            % %                DAT(jj,:)=zeros(15000,1);
            % %            end
            %                for iii=1:5
            %                    s=spectrogram(DAT(jj,3000*(ii-1)+1:ii*3000),windows,nooverlap,nfft);
            %                    s=s(1:32,:);
            %                    S{iii}=s;
            %                end
            %     SS{jj}=S;
        end
        savename=[outputDir,'\',nb,'2.mat'];
%         savename1=[outputDir1,num2str(p(ii)),'\',nb];
        %     savename1=[outputDir1,num2str(sub),'\',na];
        clear dat
        clear data1_EMG
        clear data1_EEG
        save(savename,'DAT');
        savename1=[outputdir2,'\',nb,'2.mat'];
        save(savename1,'spo2','ecg','rate','head')
%         savename2=[outputdir1,'\',nb];
%         save(savename2,'label',"label1")
        %     save(savename1,'SS');
        clear DAT position1
        clear mark1
        clear mark2
        clear aa1
        clear aa2
        clear SS
        clear S ll
    end
% end

runtime=toc
function [BT_SW_B,BT_SW_A]=filterdesign(fx1,fx2,samplingrate)
SW = [fx1 fx2] / samplingrate * 2;
[BT_SW_B,BT_SW_A] = butter( 4 , SW , 'bandpass' ); %设计巴特沃斯滤波器参数
end
function [dat,rate]=getno0data(data1,n,sam,len)
for i=1:length(n)
    mark=sam*len*30;
%     if data1(n(i),mark+1)==0
        dat(i,:)=data1(n(i),1:mark);
%     else
%         dat(i,:)=data1(n(i),1:mark);
%     end
end
%     mark=find(data1(n(i),:)==0);
%     if ~isempty(mark)
%         bb=min(mark);
%         dat1(i,:)=data1(n(i),1:bb-1);
%     else
%         dat1(i,:)=data1(n(i),:);
%     end
% end
if ceil(length(dat)/sam/30)~=len
    rate=floor(length(dat1)/len);
else
    rate=sam;
end
end
% % function    功能以加在前面，用不上了
% %     for i=1:4
% %         stp=first_point(sub)*sample(i)/256;
% %         mark0=find(data(i,:)==0,1);
% %         if ~isempty(mark0)
% %             data1(i,:)=data(i,ceil(stp):mark_EMG-1);
% %         else
% %             data1(i,:)=data(:,ceil(stp):end);
% %         end
% %     end
% % end
function [p,lp]=findlabelpos(head,h,h1)
%h 通用名称  C3
%h1 具体名称  C3M2
%看有几个同类通道
a=0;
f=strfind(head.label,h);
p=cell2mat(f);
lp=length(p);
%只有一个同类通道
if lp~=1
    a=strcmp(head.label,h1);
    if sum(a)==0
        a=strcmp(head.label,h);
    end
else
    a0=strcmp(head.label,h);
    a1=strcmp(head.label,h1);
    if sum(a0)~=0
        a=a0;
    end
    if sum(a1)~=0
        a=a1;
    end
end
% for i=1:length(a)
%     if ~isempty(a{i})
%         h(i)=a{i};
%     else
%         h(i)=0;
%     end
% end

    p=find(a==1);

% lp=length(p);
% if lp>1
%     f=strcmp(heead.label,h1);
% end
% p=find(f==1);
end

function [eeg,eog,emg,sample]=labelpos(data,head,res1,res2,EEG1,EEG1t,EEG2,EEG2t,EOG1,EOG1t,EOG2,EOG2t,EMG1,EMG1t,EMG2,EMG2t)
% for i=1:length(EEG1)%先输入C3，C3M2   若lp1》1，不用减去参考，若小，减参考
%     for j=1:length(EEG1t)
%         [e01,le1]=findlabelpos(head,EEG1{i},EEG1t{j});
%         [e02,le2]=findlabelpos(head,EEG2{i},EEG2t{j});
%     end
%     if ~isempty(e01) && ~isempty(e02)
%         e1=e01;
%         e2=e02;
%     end
% end
[e1,e2,le1,le2]=labposi(EEG1,EEG1t,EEG2,EEG2t,head);
[o1,o2,lo1,lo2]=labposi(EOG1,EOG1t,EOG2,EOG2t,head);
[r1,r2,lr1,lr2]=labposi(res1,res1,res2,res2,head);
[m1,m2,lm1,lm2]=labposi(EMG1,EMG1t,EMG2,EMG2t,head);
% for i=1:length(EOG1)
%     [o01,lo1]=findlabelpos(head,EOG1{i},EOG1t{i});
%     [o02,lo2]=findlabelpos(head,EOG2{i},EOG2t{i});
%     if ~isempty(o01) && ~isempty(o02)
%         o1=o01;
%         o2=o02;
%     end
% end

% for i=1:length(res1)
%     [r01,lr1]=findlabelpos(head,res1{i},res1{i});
%     [r02,lr2]=findlabelpos(head,res2{i},res2{i});
%     if ~isempty(r01) && ~isempty(r02)
%         r1=r01;
%         r2=r02;
%     end
% end
% 
% for i=1:length(EMG1)
%     [m01,lm1]=findlabelpos(head,EMG1{i},EMGt1{1});
%     [m02,lm2]=findlabelpos(head,EMG2{i},EMGt2{1});
%     if ~isempty(m01) && ~isempty(m02)
%         m1=m01;
%         m2=m02;
%     end
% end

if isempty(r1) && isempty(r2)
   rest1=zeros(1,size(data,2));
   rest2=rest1;
else
    rest1=data(r1,:);
    rest2=data(r2,:);
end

if le1~=1 || le2~=1
    eeg(1,:)=data(e1,:);
    eeg(2,:)=data(e2,:);
else
    eeg(1,:)=data(e1,:)-rest1;
    eeg(2,:)=data(e2,:)-rest2;
end
if lo1>1 || lo2>1
    eog(1,:)=data(o1,:);
    eog(2,:)=data(o2,:);
else
    eog(1,:)=data(o1,:)-rest1;
    eog(2,:)=data(o2,:)-rest1;
end
if (~isempty(m1) && ~isempty(m2) )  &&  m1~=m2
    m=max([m1,m2]);
    emg=data(m1,:)-data(m2,:);
elseif (~isempty(m1) && ~isempty(m2) )  &&  m1==m2
    m=m1;
    emg=data(m1,:);
elseif ~isempty(m1) || ~isempty(m2)
    m=[m1,m2];
    m0=~isempty(m);
    m=m(m0==1);
    emg=data(m,:);
end
sample(1)=head.samples(e1);
sample(2)=head.samples(e2);
sample(3)=head.samples(o1);
sample(4)=head.samples(o2);
sample(5)=head.samples(m);
end

function [e1,e2,le1,le2]=labposi(EEG1,EEG1t,EEG2,EEG2t,head)
for i=1:length(EEG1)%先输入C3，C3M2   若lp1》1，不用减去参考，若小，减参考
    for j=1:length(EEG1t)
        [e01,le1]=findlabelpos(head,EEG1{i},EEG1t{j});
        if ~isempty(e01)
            break
        end
    end
    if ~isempty(e01)
        e1=e01;
        break
    else
        e1=[];
    end
end
for i=1:length(EEG2)%先输入C3，C3M2   若lp1》1，不用减去参考，若小，减参考
    for j=1:length(EEG2t)
        [e02,le2]=findlabelpos(head,EEG2{i},EEG2t{j});
        if ~isempty(e02)
            break
        end
    end
    if  ~isempty(e02)
        e2=e02;
        break
    else
        e2=[];
    end
end
end
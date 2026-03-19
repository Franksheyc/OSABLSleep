clear
clc
warning off
% objDir1='D:\database\MASS\staged\data\SS';%读取文件地址
t='dod';
% Lna1=1;Lla1=1;
k=0;
% Lna2=0;Lla2=0;mark=0;
b=7;
samplingrate=100;

tic
OBJ1{1}='D:\database\data\ISRUC\extracted\1\data';
OBJ1{2}='D:\database\data\ISRUC\extracted\2\data';
OBJ1{3}='D:\database\data\ISRUC\extracted\3\data';
OBJ1{4}='D:\database\data\UCDDB_database\extracted\data';
OBJ1{5}='\\192.168.31.100\Data\13_公开数据集\公开数据集\临时文件夹\abc';
OBJ1{6}='\\192.168.31.100\Data\13_公开数据集\公开数据集\临时文件夹\homepap\lab\full';

OBJ2{1}='D:\database\data\ISRUC\extracted\1\label';
OBJ2{2}='D:\database\data\ISRUC\extracted\2\label';
OBJ2{3}='D:\database\data\ISRUC\extracted\3\label';
OBJ2{4}='D:\database\data\UCDDB_database\extracted\label';
OBJ2{5}='D:\database\data\abc\label';
OBJ2{6}='D:\database\data\HPAP\lab\full\label';

OBJ3{1}='D:\database\data\ISRUC\extracted\1\features\';
OBJ3{2}='D:\database\data\ISRUC\extracted\2\features\';
OBJ3{3}='D:\database\data\ISRUC\extracted\3\features\';
OBJ3{4}='D:\database\data\UCDDB_database\extracted\features\';
OBJ3{5}='D:\database\data\abc\features\';
OBJ3{6}='D:\database\data\HPAP\lab\full\features1\';
% subjects=[22 40 47 49 64 65 82 104 111 132 158 162 190];
for p=3:3%length(OBJ1)
% objDir1=['F:\sleep\data\',t,'\data\ccshs'];%读取文件地址
% objDir2=['F:\sleep\data\',t,'\label\ccshs'];
% objDir1=['H:\pshhs\data\',t,'1'];%读取文件地址
% objDir2=['F:\sleep\data\',t,'\label\shhs1'];
% outputDir = ['F:\sleep\data\',t,'\feature\ccshs'];
objDir1=OBJ1{p};
objDir2=OBJ2{p};
outputDir=OBJ3{p};
mkdir(outputDir)
%     path1=[objDir1,num2str(ij)];
%     path2=[objDir2,num2str(ij)];
n1=dir(objDir1);
n2=dir(objDir2);
% n3=dir('F:\sleep\data\shhs\feature');
mm=ceil((length(n1)-2)/1);

% for i=1:length(n3)-3
% pp(i)=str2num(n3(i+2).name(end-9:end-4));
% end
mk=1;
% hm=mm*(mk-1)+1:min(mm*mk,length(n1)-2);
% for i=hm
% pp1(i)=str2num(n1(i+2).name(end-9:end-4));
% end
% h1=length(intersect(pp,pp1));
% mk=1;
% for ii=mm*(mk-1)+1:min(mm*mk,length(n1)-2)%ceil((length(n1)-2)/6)*5+1:length(n1)-2%ceil((length(n1)-2)/6)*5%%ceil((length(n1)-2)/6)*6%1:ceil((length(n1)-2)/2)%
for ii=1:length(n1)-2%length(subjects)%
    na=[n1(ii+2).name];
    la=[n2(ii+2).name];
    filename1=[objDir1,'\',na];
    filename2=[objDir2,'\',la];
    load(filename1);
    load(filename2);
    
    unit=size(DAT,2)/samplingrate/5;
    DAT(:,1:3750*4)= DAT(:,1:3750*4)/1000;

    if ii==10
        DAT=DAT(7:end,:);
        label=label(7:end,:);
        label1=label1(7:end,:);
    end
    mark=find(sum(DAT,2)~=0);
    DAT=DAT(mark,:);
    label=label(mark);
    
    if p<=4
        label(label==5)=4;
        label(label>5)=5;
    end
    aa=find(label==5);
    bb=setdiff(1:length(label),aa);
    label=label(bb);
    DAT=DAT(bb,:);

    len=size(DAT,1);
    lla=length(label);
    lab=zeros(len,5);
    k=k+1
    %%%
    for ijk=1:len
        switch label(ijk)
            case 0
                lab(ijk,5)=1;
            case 1
                lab(ijk,1)=1;
            case 2
                lab(ijk,2)=1;
            case 3
                lab(ijk,3)=1;
            case 4
                lab(ijk,4)=1;
        end
    end
    
    C3=DAT(:,1:unit*samplingrate);
    C4=DAT(:,unit*samplingrate+1:2*unit*samplingrate);
    EOGL=DAT(:,2*unit*samplingrate+1:3*unit*samplingrate);
    EOGR=DAT(:,3*unit*samplingrate+1:4*unit*samplingrate);
    EMG =DAT(:,4*unit*samplingrate+1:end);
    % % % % % %
    
    [C3_frec,C3coe]=wavelet_features1(b,C3);
    [C4_frec,C4coe]=wavelet_features1(b,C4);
    C3_frec=struct2cell(C3_frec);
    C4_frec=struct2cell(C4_frec);
    %          C3_frec1=struct2cell(C3_frec1);
    %          C4_frec1=struct2cell(C4_frec1);
    parfor i=1:length(C3_frec)
        C3_tfs=time_features(C3_frec{i},'EEG');
        C4_tfs=time_features(C4_frec{i},'EEG');
        %              C3_tfs1=time_features(C3_frec1{i},'EEG');
        %              C4_tfs1=time_features(C4_frec1{i},'EEG');
        C3tfs{i}=C3_tfs;
        C4tfs{i}=C4_tfs;
        %              C3tfs1{i}=C3_tfs1;
        %              C4tfs1{i}=C4_tfs1;
    end
    EOGcoff=EOG_cof(EOGL,EOGR,samplingrate);
    EOGLtfs=time_features(EOGL,'EOG');
    EOGRtfs=time_features(EOGR,'EOG');
    EMGtfs=time_features(EMG,'EMG');
    u=samplingrate*(unit/6);
    %          for i=1:6
    C30_tfs=time_features(C3,'EEG');
    C40_tfs=time_features(C4,'EEG');
    %          end
    
    
    C3H=[];C4H=[];EOGLH=[];EOGRH=[];EMGH=[];
    for i=1:6
        C31=C3(:,u*(i-1)+1:u*i);
        [C3a,C3m,C3c]=Hjorth_features(C31);
        C41=C4(:,u*(i-1)+1:u*i);
        [C4a,C4m,C4c]=Hjorth_features(C41);
        EOGL1=EOGL(:,u*(i-1)+1:u*i);
        [EOGLa,EOGLm,EOGLc]=Hjorth_features(EOGL1);
        EOGR1=EOGR(:,u*(i-1)+1:u*i);
        [EOGRa,EOGRm,EOGRc]=Hjorth_features(EOGR1);
        EMG1=EMG(:,u*(i-1)+1:u*i);
        [EMGa,EMGm,EMGc]=Hjorth_features(EMG1);
        C3H=[C3H C3a,C3m,C3c];
        C4H=[C4H C4a,C4m,C4c];
        EOGLH=[EOGLH EOGLa,EOGLm,EOGLc];
        EOGRH=[EOGRH EOGRa,EOGRm,EOGRc];
        EMGH=[EMGH EMGa,EMGm,EMGc];
    end
    %          C3coe{ij}=C3_fcoe;
    %          C4coe{ij}=C4_fcoe;
    %          C3tfs{ij}=C3tfs1;
    %          C4tfs{ij}=C4tfs1;
    %          EOGLtfs{ij}=EOGL_tfs;
    %          EOGRtfs{ij}=EOGR_tfs;
    %          EOGcoff{ij}=EOG_coff;
    %          EMGtfs{ij}=EMG_tfs;
    
    savename=[outputDir,na];
    save(savename,'C3coe','C4coe','C3tfs','C4tfs','C30_tfs','C40_tfs','EOGLtfs','EOGRtfs','EOGcoff','EMGtfs','C3H','C4H','EOGLH','EOGRH','EMGH','label','lab');
    clear C3coe C4coe C3tfs C4tfs C3coe1 C4coe1 C3tfs1 C4tfs1 EOGLtfs EOGRtfs EOGcoff EMGtfs C3 C4 EOGL EOGR EMG C30_tfs C40_tfs C3H C4H EOGLH EOGRH EMGH
    leng(k)=len;
    len1=length(find(label~=5));
    leng_no9(k)=len1;
end

total=sum(leng);
totalnum_no9=sum(leng_no9);
savename1=[outputDir,'info.mat'];
save(savename1,'leng','leng_no9','total','totalnum_no9');
toc
end
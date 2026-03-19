%%%%%%%%%%%%%%%使用全部特征，time 10s/part%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%在event的基础上改，将呼吸仅放入第10个fbls之后，
clear
warning off all;
format compact;
add='mesa';

Dir=['D:\E\sleep\open database\features\',add];%cassette  telemetry
Dir1=['D:\E\sleep\open database\breathfeatures\features\',add];
outdir=['D:\E\sleep\stage wave breath heart result\',add];
% Dir=['F:\sleep\open database\features\',add];%cassette  telemetry
% outdir=['F:\sleep\open database\result\',add];
% Dir=['F:\sleep\open database\features\','SHHS1'];
%%%
%%%%EDF==20 edf20   EDF==78 edf78   EDF==0 其他数据集

EDF=0;
epochs = 1;
n=5;
h=5;%bls enhance窗
Time_related= [8 9 10];
mode=2;% timing mode
con_st=0.75;
si=20;bs=[1.8 1.2 1 0.9 0.7];%timing features[1.8 1.2 1 0.9 0.8]
bn=8;%测试集中每个SS中取多少组做训练
C = 2^-24; s = .8;%the l2 regularization parameter and the shrinkage scale of the enhancement nodes  C = 2^-30
times=2;%第一次bls循环次数
filename1=[Dir,'\',add,'.mat'];
filename2=[Dir,'\',add,'_tt.mat'];

load('demography_selected.mat')
eval(['osacha=',add,'(:,8);']);%ahi3   ahi4 9
eval(['bmi=',add,'(:,5);']);
eval(['age=',add,'(:,3);']);

[breathfeatures,bfcon,fb,fb0,fbe,labelb]=norbreattf(Dir1);
Labb=label2lab(labelb);
%mode 取1为单独信号   mode取2为全体信号
%bu 取0不用EMG与EOG   取1用全部使用  2为只用EEG+EOG
%mo==1 取第一通道脑电，mo==2取第二通道脑电
xadd=[Dir,'\',add,'trte.mat'];
xadd1=[Dir,'\',add,'trte0.mat'];
savename0=[Dir,'\',add,'_nomalized.mat'];
if exist(savename0)==2
    load(savename0)
else
mode1=2;bu=1;mod=2;
softmax1=@(x)exp(x)./sum(exp(x)')';
% [FF,CFF,label,leng,fo]=datage(filename1,filename2,mode1,bu);
[FF,CFF,label,leng,fo,fmark,fml,olen,kl,Mode]=datage_largedata1(filename1,filename2,mode1,bu,mod);
li=[];
for i=1:length(leng)
    li=[li 0.8*(1:leng(i))/leng(i)];
end
FF=[FF li'];
save(savename0,'FF','CFF','label','leng','fo','fmark','fml','olen','kl','Mode')
end
clear CFF

time_related=[5 5];para=kaiser(15,1);%para=[0.7 0.7 0.75 0.75  0.85 0.9 0.95 1 0.9 0.8 0.7 0.7 0.7 0.6 0.6];
savename1=[Dir,'\',add,num2str(time_related),'times_expand.mat'];
if exist(savename1)==2
    load(savename1)
else
    [FF1,f_ex,fe_ex,f0_ex,nfp_ex]=generate_exfeature(FF,time_related,Mode,fmark,fml,para,leng,olen,kl);
    save(savename1,'FF1','f_ex','fe_ex','f0_ex','nfp_ex');
end
% [FF,index,phis,fo]=fea_select(FF,label,fo,0.95,1);%mRMR
result1=[];result=[];test_lab=[];test_label=[];
% if strcmp(add,'sleep-EDF')
%     if EDF==78
%         leng=leng(1:39);
%         d=1:sum(leng(1:39));
%         FF=FF(d,:);
%         CFF=CFF(d,:);
%         lable=label(d);
%     end
%     [leng,lengo]=sleepEDFleng(leng);
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
len=size(FF,2);
label(label==0)=5;
% [FF,CFF,label,leng]=banwake(FF,CFF,label,leng,0.1);
clear Lab
Lab=label2lab(label);
% label=single(label);
% Lab=single(Lab);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%找出一部分样本，作为测试集%%%%%%%%%%%%%%%%%%%%
if length(leng)>6000
    hd=max(6000,floor(length(leng)/2));
else
    hd=length(leng);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hd=length(leng)-3;%测试copy6用
CCC0=0;%CCC用来储存历次结果，第一次为0，是为了方便第一次 multibls 的使用
% % CCC0=0.84;%针对shhs2
Mark=randperm(hd)+1;
for i=1:hd
    K(i)=sum(leng(1:i));
end


flods=5;

% % indict=crossvalind('Kfold',floor(hd/flod)*flod,flod);
% indict=crossvalind('Kfold',hd,flods);
indict=ones(1,hd);
remk=rem(1:hd,flods);
for i=1:flods
    lk=find(remk==i-1);
    indict(lk)=i;
end
indict=indict';

% flods=1;
% indict=zeros(1,length(leng));
% ih=randperm(length(leng));
% indict(ih(1:ceil(length(leng)*0.3)))=1;

[group1,group2,group3,group4,groupc,indictg1,indictg2,indictg3,indictg4,indictgc]=groupdat(age,osacha,flods);
ACCo_pre=cell(flods,epochs);ACC_pre=cell(flods,epochs);accuracy_pre=cell(flods,epochs);
Precidion_pre=cell(flods,epochs);Recall_pre=cell(flods,epochs);F1SCORE_pre=cell(flods,epochs);
F1score_pre=cell(flods,epochs);Kappa_pre=cell(flods,epochs);Mcc_pre=cell(flods,epochs);
train_length=zeros(flods,epochs);trainingacc=cell(flods,epochs);
brelow=breathfeatures(:,1);
for k=1:flods
    [ss,ss1,outsub]=gettrte(group1,group2,group3,group4,groupc,indictg1,indictg2,indictg3,indictg4,indictgc,k,length(leng));
%     ss1=(indict == k);%test
%     ss=~ss1;%train
%     ss=find(ss==1);
%     ss1=find(ss1==1);

%     if k>1
%        FF=[train_x;test_x];
%        FF1=[train_x0;test_x0];
%        train_y(train_y>1)=1;
%        label=[train_yy;test_yy];
%        Lab=[train_y;test_y];
%        FF=FF(remark,:);
%        FF1=FF1(remark,:);
%        label=label(remark,:);
%        Lab=Lab(remark,:);
%     end
%     clear train_x train_x0 train_y train_yy test_x test_x0 test_y test_yy
    if k>1
        load(savename0,'FF');
        [breathfeatures,~,~,~,~,~]=norbreattf(Dir1);
    end
    marktr=getmark(ss,K);
    if length(marktr)>1000000
        outsub1=outsub(1:length(outsub)/3);%
        ss=setdiff(ss,outsub1);
%         ss=ss(1:max(length(ss1)*2,1200));
        marktr=getmark(ss,K);
    end
    markte=getmark(ss1,K);
    train_x=FF(marktr,:);test_x=FF(markte,:);
    clear FF 
    
    if k>1
        load(savename1,'FF1');
    end
    train_x0=FF1(marktr,:);test_x0=FF1(markte,:);
    clear FF1
    train_y=Lab(marktr,:);test_y=Lab(markte,:);                                                                                                                                                     
    train_yy=label(marktr,:);test_yy=label(markte,:);

    train_y1=Labb(marktr,:);test_y1=Labb(markte,:);                                                                                                                                                       
    train_yy1=labelb(marktr,:);test_yy1=labelb(markte,:);

    train_xb=breathfeatures(marktr,:);test_xb=breathfeatures(markte,:);
    brelowr=brelow(marktr);brelowe=brelow(markte);
    brelowr=find(brelowr>0.5);brelowe=find(brelowe>0.5);
    clear breathfeatures

    train_err=zeros(1,epochs);test_err=zeros(1,epochs);
    train_time=zeros(1,epochs);test_time=zeros(1,epochs);
    train_x0=train_x0(:,1:sum(f_ex));test_x0=test_x0(:,1:sum(f_ex));

    [train_x, test_x]=pre_zca(train_x,test_x);%白化处理  使训练更以收敛
    [train_x0, test_x0]=pre_zca(train_x0,test_x0);
%     [train_xb, test_xb]=pre_zca(train_xb,test_xb);
    kk=1;
     [lx1,lx2]=size(train_x);
    save(xadd,'train_x','test_x')
    save(xadd1,'train_x0','test_x0')
    clear train_x test_x train_x0 test_x0
   

    study_rate=0.15; xx=zeros(lx1,5); yy=zeros(lx1,1); cr1=ones(lx1,1);ce1=ones(lx1,1);
    len0=leng(ss);
    for bo=1:length(ss)
        ko0(bo)=sum(len0(1:bo));
    end
    ko0=[0 ko0];
    seeds=256;
    rng(seeds)
    [train_y,study_rate,si]=trainybanlance(kk,train_yy,train_y,study_rate,xx,yy,cr1,train_yy,con_st,si);


    if kk==1
        ten=0;par=[];pare=[];par1=[];pare1=[];
    end
    wh=[];beta11=[];
    f2=[];%f2为新增特征种类数
    K0=[];
     
    
%%%%%%%%%%%%%呼吸
time_related1=9;
[N1,N2,fe,fe1]=trainpar(len,1,1,ten,time_related1);
lenb=size(train_xb,2);nfpb=0;N1b=N1(1:end-1);N2b=N2(1:end-1);
[frex,frex1]=timecausal0(time_related1,leng(ss),5);
[feex,feex1]=timecausal0(time_related1,leng(ss1),5);
ofb=fb;ofb0=fb0;ofbe=fbe;nb0=5;
[frexb,frexb1]=timecausal0(time_related1,leng(ss),2);
[feexb,feexb1]=timecausal0(time_related1,leng(ss1),2);
train_y1(train_y1(:,1)==1)=1.5;
W1=location_label(train_yy1,4,2);
% train_y1=train_y1+W1/3;
sib=[3];bsb=[1.1,1];
for i=1:1%train_y1 是呼吸暂停事件的标签
    block1=1;
    par_0=[];par_2=[];
    [trainacc,testacc,xx20,x20,yy20,y20,~,con0,~,tn]=blscb(train_xb,train_y1,test_xb,test_y1,s,C,h,ofb,ofb0,[],[],N1b,N2b,ofbe,[],nfpb,leng,ss1);
    [C_train_x,C_test_x,cr1,ce1,ftr,fte,ft,ft0]=time_feas_b(xx20,x20,y20,yy20,time_related1,ss,ss1,leng,mode,train_yy1,test_y1,sib,bsb,frexb,frexb1,feexb,feexb1);
%     [C_train_x, C_test_x]=pre_zca(C_train_x,C_test_x);
    [y_te0,y_tr0,x_te0,x_tr0,~,~,tnl,tns,bil]=conf_rec(C_train_x,C_test_x,y20,yy20,test_y1,train_y1,cr1,ce1,s,C,h,1,ft,ft0,[],N1b,N2b,[],[],con_st,leng);
    clear C_test_x C_train_x cr1 ce1 ftr fte ft ft0
    [ofb,ofb0,nfpb]=blstimekind(size(train_xb,2),ofb);
    [cono_1,con_1,acc_1,pre_1,rec_1,sp_1,f1_1,ka_1,mc_1] = Evaluation(y20,test_y1,2);
    [~, ~, yo ,mae, rmse,ybro,ybeo] = osares(leng,ss,ss1,yy20,y20,osacha);
    [statisticosa]=osasta(yo,osacha(ss1));
    MAE(k,block1)=mae;RMSE(k,block1)=rmse;statisosa{k,block1}=statisticosa;
    cono_osa{k,block1}=cono_1;
    con_osa{k,block1}=con_1;
    accuracy_osa{k,block1}=acc_1;
    precision_osa{k,block1}=1;
    recall_osa{k,block1}=rec_1;
    specificity_osa{k,block1}=sp_1;
    f1score_osa{k,block1}=f1_1;
    kappa_osa{k,block1}=ka_1;
    mcc_osa{k,block1}=mc_1;
    train_acc_osa(k,block1)=trainacc;
    test_acc_osa(k,block1)=testacc;
    mf1_osa(k,block1)=mean(f1_1);
    ahiyy{k,block1}=yy20;
    ahiy{k,block1}=y20;
end


rng(seeds)


%% %%%%%%%%%%%%%%%   
block=1;
    [N1,N2,fe,fe1]=trainpar(len,1,block,ten,time_related);
    [f1,f0,nfp]=blstimekind(lx2,fo);
%     [trainacc,testacc,xx1,x1,yy1,y1,par10,con0,train_y,tn]=blsc(xadd,xadd1,train_y,test_y,s,C,h,f1,f0,par1,pare,N1,N2,fe,fe1,nfp,leng,ss1);
    [trainacc,testacc,xx1,x1,yy1,y1,par10,con0,train_y,tn]=blsc(xadd,xadd1,[],[],train_y,test_y,s,C,h,f1,f0,par1,pare,N1,N2,fe,fe1,nfp,leng,ss1);
    subs=plottimes(test_yy,test_y,y1,x1,leng,ss1,[1,0],0,0);
    subjectresultf(k,block).fbls=subs;
    [confusiono_pre1,confusion_pre1,accuracy_pre1,Precidion_pre1,Recall_pre1,Specificity_pre1,F1SCORE_pre1,Kappa_pre1,mcc_pre1]=resultstatsic(y1,test_y,n,k);%CCC
    confusiono{k,block}=confusiono_pre1;
    confusion{k,block}=confusion_pre1;
    accuracy{k,block}=accuracy_pre1;
    precision{k,block}=Precidion_pre1;
    recall{k,block}=Recall_pre1;
    specificity{k,block}=Specificity_pre1;
    f1score{k,block}=F1SCORE_pre1;
    kappa{k,block}=Kappa_pre1;
    mcc{k,block}=mcc_pre1;
    Par{k,block}=par10;
%     Pare{k,block}=pare;
    train_acc(k,block)=trainacc;
    test_acc(k,block)=testacc
    mf1(k,block)=mean(F1SCORE_pre1)

%% %%%%%%%%%%%%%%%%
    block=2;
    N1=N1(1:4); 
% [xx,yy,x,y,par,leen,trainacc,testacc,tn]=featurebasedbls(fo,f_ex,fe_ex,f0_ex,nfp_ex,[train_x,xx1],[test_x,x1],train_x0,test_x0,train_y,test_y,...
%         leng,s,C,h,par,pare,N1,N2,fe,fe1,ss,ss1);
[xx,yy,x,y,par,trainacc,testacc,tn,train_y]=featurebasedbls(fo,f_ex,fe_ex,f0_ex,nfp_ex,xadd,xadd1,xx1,x1,train_y,test_y,leng,s,C,h,par,pare,N1,N2,fe,fe1,ss,ss1);
    subs=plottimes(test_yy,test_y,y,x,leng,ss1,[1,0],0,0);
    subjectresultf(k,block).fbls=subs;
    [confusiono_pre1,confusion_pre1,accuracy_pre1,Precidion_pre1,Recall_pre1,Specificity_pre1,F1SCORE_pre1,Kappa_pre1,mcc_pre1]=resultstatsic(y,test_y,n,k);%CCC
    confusiono{k,block}=confusiono_pre1;
    confusion{k,block}=confusion_pre1;
    accuracy{k,block}=accuracy_pre1;
    precision{k,block}=Precidion_pre1;
    recall{k,block}=Recall_pre1;
    specificity{k,block}=Specificity_pre1;
    f1score{k,block}=F1SCORE_pre1;
    kappa{k,block}=Kappa_pre1;
    mcc{k,block}=mcc_pre1;
    Par{k,block}=par;
%     Pare{k,block}=pare;
    train_acc(k,block)=trainacc;
    test_acc(k,block)=testacc
    mf1(k,block)=mean(F1SCORE_pre1)

%% %%%%%%%%%%%%%%%%
block1=block1+1;
[trainacc,testacc,yy20,y20,xx20,x20,cono_1,con_1,acc_1,pre_1,rec_1,sp_1,f1_1,ka_1,mc_1,mae,rmse,ybro,ybeo,...
    statisticosa,ofb1,~,~]=blsosa(train_xb(:,1:sum(ofb)),test_xb(:,1:sum(ofb)),train_y1,test_y1,label2lab(yy20),label2lab(y20),...
    yy,y,leng,s,C,h,ss,ss1,osacha,block1,N1b,N2b,ofb,ofbe);
MAE(k,block1)=mae;RMSE(k,block1)=rmse;statisosa{k,block1}=statisticosa;
cono_osa{k,block1}=cono_1;
con_osa{k,block1}=con_1;
accuracy_osa{k,block1}=acc_1;
precision_osa{k,block1}=1;
recall_osa{k,block1}=rec_1;
specificity_osa{k,block1}=sp_1;
f1score_osa{k,block1}=f1_1;
kappa_osa{k,block1}=ka_1;
mcc_osa{k,block1}=mc_1;
train_acc_osa(k,block1)=trainacc;
test_acc_osa(k,block1)=testacc;
mf1_osa(k,block1)=mean(f1_1);
ahiyy{k,block1}=yy20;
ahiy{k,block1}=y20;

ybe0=zeros(size(y_te0,1),1);ybr0=zeros(size(y_tr0,1),1);
% %%%% sample wise enhance
obr=find(yy20==1);%有呼吸事件的帧，但未必是osa
obe=find(y20==1);
% obr=intersect(obr,brelowr);%判断是osa，且有呼吸事件的帧
% obe=intersect(obe,brelowe);
%%
rng(seeds)
cr=sort(xx')';
cr1=cr(:,end);
[train_y,study_rate,si]=trainybanlance(kk,train_yy,train_y,study_rate,xx,yy,cr1,y,con_st,si);

W=location_label(train_yy,10,5);
yy201=ones(length(yy20),1);yy201(yy20==1)=1.5;
W=W.*yy201;
train_y=train_y+W/2;
clear yy201

block=3;
ban=3;%ceil(time_related1/2)+3;%obr=[];obe=[];
time_related1=9;
ten=(time_related1*2+1)*5;
[N1,N2,fe,fe1]=trainpar(len,1,block,ten,time_related1);
[f1,f0,nfp]=blstimekind(lx2+(time_related1*2+1)*5,fo);

train_xb1=time_causal(xx20,1,2);
test_xb1=time_causal(x20,1,2);fb1=[3 3];fbe1={6};fb01=[2 5];
[xx1,yy1,x1,y1,par1,trainacc,testacc]=expandebls(xadd,xadd1,train_y,test_y,xx,x,time_related1,s,C,h,f1,fo,...
    [],pare1,N1,N2,fe,fe1,nfp,leng,ss,ss1,train_xb1,test_xb1,fb1,fb01,fbe1,obr,obe,ban); 
    subs=plottimes(test_yy,test_y,y1,x1,leng,ss1,[1,0],0,0);
    subjectresultf(k,block).fbls=subs;
       [confusiono_pre1,confusion_pre1,accuracy_pre1,Precidion_pre1,Recall_pre1,Specificity_pre1,F1SCORE_pre1,Kappa_pre1,mcc_pre1]=resultstatsic(y1,test_y,n,k);%CCC
    confusiono{k,block}=confusiono_pre1;
    confusion{k,block}=confusion_pre1;
    accuracy{k,block}=accuracy_pre1;
    precision{k,block}=Precidion_pre1;
    recall{k,block}=Recall_pre1;
    specificity{k,block}=Specificity_pre1;
    f1score{k,block}=F1SCORE_pre1;
    kappa{k,block}=Kappa_pre1;
    mcc{k,block}=mcc_pre1;
    Par{k,block}=par1;
%     Pare{k,block}=pare;
    train_acc(k,block)=trainacc;
    test_acc(k,block)=testacc;
    mf1(k,block)=mean(F1SCORE_pre1);

%% %%%%%%%%%%%%%%%%
    block=4;
    N1=N1(1:4);
%     para=[0.6 0.6 0.6 0.6 0.75 0.8 0.85 0.9 0.95 1 0.9 0.8 0.7 0.7 0.7 0.5 0.5 0.5 0.5];
%     [xx,yy,x,y,par,leen,trainacc,testacc,tn]=featurebasedbls(fo,f_ex,fe_ex,f0_ex,nfp_ex,[train_x,xx1],[test_x,x1],train_y,test_y,...
%         train_x0,test_x0,leng,s,C,h,par,pare,N1,N2,fe(1:end-1),fe1,ss,ss1);
[xx,yy,x,y,par,trainacc,testacc,tn,train_y]=featurebasedbls(fo,f_ex,fe_ex,f0_ex,nfp_ex,xadd,xadd1,xx1,x1,train_y,test_y,leng,s,C,h,par,pare,N1,N2,fe,fe1,ss,ss1);
    subs=plottimes(test_yy,test_y,y,x,leng,ss1,[1,0],0,0);
    subjectresultf(k,block).fbls=subs;
    [confusiono_pre1,confusion_pre1,accuracy_pre1,Precidion_pre1,Recall_pre1,Specificity_pre1,F1SCORE_pre1,Kappa_pre1,mcc_pre1]=resultstatsic(y,test_y,n,k);%CCC
    confusiono{k,block}=confusiono_pre1;
    confusion{k,block}=confusion_pre1;
    accuracy{k,block}=accuracy_pre1;
    precision{k,block}=Precidion_pre1;
    recall{k,block}=Recall_pre1;
    specificity{k,block}=Specificity_pre1;
    f1score{k,block}=F1SCORE_pre1;
    kappa{k,block}=Kappa_pre1;
    mcc{k,block}=mcc_pre1;
    Par{k,block}=par;
%     Pare{k,block}=pare;
    train_acc(k,block)=trainacc;
    test_acc(k,block)=testacc
    mf1(k,block)=mean(F1SCORE_pre1)
    
%% %%%%%%%%%%%%%%%%
    cr=sort(xx')';
    cr1=cr(:,end);
    [train_y,study_rate,si]=trainybanlance(kk,train_yy,train_y,study_rate,xx,yy,cr1,y,con_st,si);
    block=5;
%     [train_y,study_rate,si]=trainybanlance(block,train_x,train_yy,train_y,study_rate,xx,yy,cr1,train_yy,con_st,si);
    time_related1=11;
    ten=(time_related1*2+1)*5;
    [N1,N2,fe,fe1]=trainpar(len,1,block,ten,time_related1);
    [f1,f0,nfp]=blstimekind(lx2+(time_related1*2+1)*5,fo);
    [xx1,yy1,x1,y1,par1,trainacc,testacc]=expandebls(xadd,xadd1,train_y,test_y,xx,x,time_related1,s,C,h,f1,fo,...
    [],pare1,N1,N2,fe,fe1,nfp,leng,ss,ss1,train_xb,test_xb,fb,fb0,fbe,[],[],ban); 
    subs=plottimes(test_yy,test_y,y1,x1,leng,ss1,[1,0],0,0);
    subjectresultf(k,block).fbls=subs;
    [confusiono_pre1,confusion_pre1,accuracy_pre1,Precidion_pre1,Recall_pre1,Specificity_pre1,F1SCORE_pre1,Kappa_pre1,mcc_pre1]=resultstatsic(y1,test_y,n,k);%CCC
    confusiono{k,block}=confusiono_pre1;
    confusion{k,block}=confusion_pre1;
    accuracy{k,block}=accuracy_pre1;
    precision{k,block}=Precidion_pre1;
    recall{k,block}=Recall_pre1;
    specificity{k,block}=Specificity_pre1;
    f1score{k,block}=F1SCORE_pre1;
    kappa{k,block}=Kappa_pre1;
    mcc{k,block}=mcc_pre1;
    Par{k,block}=par1;
%     Pare{k,block}=pare;
    train_acc(k,block)=trainacc;
    test_acc(k,block)=testacc
    mf1(k,block)=mean(F1SCORE_pre1)

%% %%%%%%%%%%%%%%%%
    block=6;
    N1=N1(1:4);
%     para=[0.6 0.6 0.6 0.6 0.75 0.8 0.85 0.9 0.95 1 0.9 0.8 0.7 0.7 0.7 0.5 0.5 0.5 0.5];
% [xx,yy,x,y,par,trainacc,testacc,tn,train_y]=featurebasedbls(fo,f_ex,fe_ex,f0_ex,nfp_ex,add,add1,xx1,x1,train_y,test_y,leng,s,C,h,par,pare,N1,N2,fe,fe1,ss,ss1);
%     subs=plottimes(test_yy,test_y,y,x,leng,ss1,[1,0],0,0);
    [xx,yy,x,y,par,trainacc,testacc,tn,train_y]=featurebasedbls(fo,f_ex,fe_ex,f0_ex,nfp_ex,xadd,xadd1,xx1,x1,train_y,test_y,leng,s,C,h,par,pare,N1,N2,fe,fe1,ss,ss1);
    subjectresultf(k,block).fbls=subs;
    [confusiono_pre1,confusion_pre1,accuracy_pre1,Precidion_pre1,Recall_pre1,Specificity_pre1,F1SCORE_pre1,Kappa_pre1,mcc_pre1]=resultstatsic(y,test_y,n,k);%CCC
    confusiono{k,block}=confusiono_pre1;
    confusion{k,block}=confusion_pre1;
    accuracy{k,block}=accuracy_pre1;
    precision{k,block}=Precidion_pre1;
    recall{k,block}=Recall_pre1;
    specificity{k,block}=Specificity_pre1;
    f1score{k,block}=F1SCORE_pre1;
    kappa{k,block}=Kappa_pre1;
    mcc{k,block}=mcc_pre1;
    Par{k,block}=par;
%     Pare{k,block}=pare;
    train_acc(k,block)=trainacc;
    test_acc(k,block)=testacc
    mf1(k,block)=mean(F1SCORE_pre1)

%% %%%%%%%%%%%%%%%%
    cr=sort(xx')';
    cr1=cr(:,end);
    [train_y,study_rate,si]=trainybanlance(kk,train_yy,train_y,study_rate,xx,yy,cr1,y,con_st,si);
    block=7;
%     [train_y,study_rate,si]=trainybanlance(block,train_x,train_yy,train_y,study_rate,xx,yy,cr1,train_yy,con_st,si);
    time_related1=11;
    ten=(time_related1*2+1)*5;
    [N1,N2,fe,fe1]=trainpar(len,1,block,ten,time_related1);
    [f1,f0,nfp]=blstimekind(lx2+(time_related1*2+1)*5,fo);
    [xx1,yy1,x1,y1,par1,trainacc,testacc]=expandebls(xadd,xadd1,train_y,test_y,xx,x,time_related1,s,C,h,f1,fo,...
    [],pare1,N1,N2,fe,fe1,nfp,leng,ss,ss1,train_xb,test_xb,fb,fb0,fbe,[],[],ban); 
    subs=plottimes(test_yy,test_y,y1,x1,leng,ss1,[1,0],0,0);
    subjectresultf(k,block).fbls=subs;
    [confusiono_pre1,confusion_pre1,accuracy_pre1,Precidion_pre1,Recall_pre1,Specificity_pre1,F1SCORE_pre1,Kappa_pre1,mcc_pre1]=resultstatsic(y1,test_y,n,k);%CCC
    confusiono{k,block}=confusiono_pre1;
    confusion{k,block}=confusion_pre1;
    accuracy{k,block}=accuracy_pre1;
    precision{k,block}=Precidion_pre1;
    recall{k,block}=Recall_pre1;
    specificity{k,block}=Specificity_pre1;
    f1score{k,block}=F1SCORE_pre1;
    kappa{k,block}=Kappa_pre1;
    mcc{k,block}=mcc_pre1;
    Par{k,block}=par1;
%     Pare{k,block}=pare;
    train_acc(k,block)=trainacc;
    test_acc(k,block)=testacc
    mf1(k,block)=mean(F1SCORE_pre1)

%% %%%%%%%%%%%%%%%%
    block=8;
    N1=N1(1:4);
%     para=[0.6 0.6 0.6 0.6 0.75 0.8 0.85 0.9 0.95 1 0.9 0.8 0.7 0.7 0.7 0.5 0.5 0.5 0.5];
%     [xx,yy,x,y,par,leen,trainacc,testacc,tn]=featurebasedbls(fo,f_ex,fe_ex,f0_ex,nfp_ex,[train_x,xx1],[test_x,x1],train_y,test_y,...
%         train_x0,test_x0,leng,s,C,h,par,pare,N1,N2,fe(1:end-1),fe1,ss,ss1);
[xx,yy,x,y,par,trainacc,testacc,tn,train_y]=featurebasedbls(fo,f_ex,fe_ex,f0_ex,nfp_ex,xadd,xadd1,xx1,x1,train_y,test_y,leng,s,C,h,par,pare,N1,N2,fe,fe1,ss,ss1);
    subs=plottimes(test_yy,test_y,y,x,leng,ss1,[1,0],0,0);
    subjectresultf(k,block).fbls=subs;
    [confusiono_pre1,confusion_pre1,accuracy_pre1,Precidion_pre1,Recall_pre1,Specificity_pre1,F1SCORE_pre1,Kappa_pre1,mcc_pre1]=resultstatsic(y,test_y,n,k);%CCC
    confusiono{k,block}=confusiono_pre1;
    confusion{k,block}=confusion_pre1;
    accuracy{k,block}=accuracy_pre1;
    precision{k,block}=Precidion_pre1;
    recall{k,block}=Recall_pre1;
    specificity{k,block}=Specificity_pre1;
    f1score{k,block}=F1SCORE_pre1;
    kappa{k,block}=Kappa_pre1;
    mcc{k,block}=mcc_pre1;
    Par{k,block}=par;
%     Pare{k,block}=pare;
    train_acc(k,block)=trainacc;
    test_acc(k,block)=testacc
    mf1(k,block)=mean(F1SCORE_pre1)

%% %%%%%%%%%%%%%%%%
    cr=sort(xx')';
    cr1=cr(:,end);
    [train_y,study_rate,si]=trainybanlance(kk,train_yy,train_y,study_rate,xx,yy,cr1,y,con_st,si);
    block=9;
%     [train_y,study_rate,si]=trainybanlance(block,train_x,train_yy,train_y,study_rate,xx,yy,cr1,train_yy,con_st,si);
    time_related1=11;
    ten=(time_related1*2+1)*5;
    [N1,N2,fe,fe1]=trainpar(len,1,block,ten,time_related1);
    [f1,f0,nfp]=blstimekind(lx2+(time_related1*2+1)*5,fo);
    [xx1,yy1,x1,y1,par1,trainacc,testacc]=expandebls(xadd,xadd1,train_y,test_y,xx,x,time_related1,s,C,h,f1,fo,...
    [],pare1,N1,N2,fe,fe1,nfp,leng,ss,ss1,train_xb,test_xb,fb,fb0,fbe,[],[],ban); 
    subs=plottimes(test_yy,test_y,y1,x1,leng,ss1,[1,0],0,0);
    subjectresultf(k,block).fbls=subs;
    [confusiono_pre1,confusion_pre1,accuracy_pre1,Precidion_pre1,Recall_pre1,Specificity_pre1,F1SCORE_pre1,Kappa_pre1,mcc_pre1]=resultstatsic(y1,test_y,n,k);%CCC
    confusiono{k,block}=confusiono_pre1;
    confusion{k,block}=confusion_pre1;
    accuracy{k,block}=accuracy_pre1;
    precision{k,block}=Precidion_pre1;
    recall{k,block}=Recall_pre1;
    specificity{k,block}=Specificity_pre1;
    f1score{k,block}=F1SCORE_pre1;
    kappa{k,block}=Kappa_pre1;
    mcc{k,block}=mcc_pre1;
    Par{k,block}=par1;
%     Pare{k,block}=pare;
    train_acc(k,block)=trainacc;
    test_acc(k,block)=testacc
    mf1(k,block)=mean(F1SCORE_pre1)

%% %%%%%%%%%%%%%%%%
    block=10;
    N1=N1(1:4);
%     [xx,yy,x,y,par,leen,trainacc,testacc,tn]=featurebasedbls(fo,f_ex,fe_ex,f0_ex,nfp_ex,[train_x,xx1],[test_x,x1],train_y,test_y,...
%         train_x0,test_x0,leng,s,C,h,par,pare,N1,N2,fe(1:end-1),fe1,ss,ss1);
[xx,yy,x,y,par,trainacc,testacc,tn,train_y]=featurebasedbls(fo,f_ex,fe_ex,f0_ex,nfp_ex,xadd,xadd1,xx1,x1,train_y,test_y,leng,s,C,h,par,pare,N1,N2,fe,fe1,ss,ss1);
    subs=plottimes(test_yy,test_y,y,x,leng,ss1,[1,0],0,0);
    subjectresultf(k,block).fbls=subs;
    [confusiono_pre1,confusion_pre1,accuracy_pre1,Precidion_pre1,Recall_pre1,Specificity_pre1,F1SCORE_pre1,Kappa_pre1,mcc_pre1]=resultstatsic(y,test_y,n,k);%CCC
    confusiono{k,block}=confusiono_pre1;
    confusion{k,block}=confusion_pre1;
    accuracy{k,block}=accuracy_pre1;
    precision{k,block}=Precidion_pre1;
    recall{k,block}=Recall_pre1;
    specificity{k,block}=Specificity_pre1;
    f1score{k,block}=F1SCORE_pre1;
    kappa{k,block}=Kappa_pre1;
    mcc{k,block}=mcc_pre1;
    Par{k,block}=par;
%     Pare{k,block}=pare;
    train_acc(k,block)=trainacc;
    test_acc(k,block)=testacc
    mf1(k,block)=mean(F1SCORE_pre1)
%% osa事件用来变换特征

block1=block1+1;
[trainacc,testacc,yy20,y20,xx20,x20,cono_1,con_1,acc_1,pre_1,rec_1,sp_1,f1_1,ka_1,mc_1,mae,rmse,ybro,ybeo,...
    statisticosa,ofb1,~,~]=blsosa(train_xb(:,1:sum(ofb)),test_xb(:,1:sum(ofb)),train_y1,test_y1,label2lab(yy20),label2lab(y20),...
    yy,y,leng,s,C,h,ss,ss1,osacha,block1,N1b,N2b,ofb,ofbe);
MAE(k,block1)=mae;RMSE(k,block1)=rmse;statisosa{k,block1}=statisticosa;
cono_osa{k,block1}=cono_1;
con_osa{k,block1}=con_1;
accuracy_osa{k,block1}=acc_1;
precision_osa{k,block1}=1;
recall_osa{k,block1}=rec_1;
specificity_osa{k,block1}=sp_1;
f1score_osa{k,block1}=f1_1;
kappa_osa{k,block1}=ka_1;
mcc_osa{k,block1}=mc_1;
train_acc_osa(k,block1)=trainacc;
test_acc_osa(k,block1)=testacc;
mf1_osa(k,block1)=mean(f1_1);
ahiyy{k,block1}=yy20;
ahiy{k,block1}=y20;
%%
rng(seeds)
    cr=sort(xx')';
    cr1=cr(:,end);
    [train_y,study_rate,si]=trainybanlance(kk,train_yy,train_y,study_rate,xx,yy,cr1,y,con_st,si);
    obr=find(yy20==1);%有呼吸事件的帧，但未必是osa
    obe=find(y20==1);
%     obr=intersect(obr,brelowr);%判断是osa，且有呼吸事件的帧
%     obe=intersect(obe,brelowe);
    block=11;
%     [train_y,study_rate,si]=trainybanlance(block,train_x,train_yy,train_y,study_rate,xx,yy,cr1,train_yy,con_st,si);
    time_related1=11;
    ten=(time_related1*2+1)*5;
    [N1,N2,fe,fe1]=trainpar(len,1,block,ten,time_related1);
    [f1,f0,nfp]=blstimekind(lx2+(time_related1*2+1)*5,fo);

    train_xb1=time_causal(xx20,1,2);
test_xb1=time_causal(x20,1,2);fb1=[3 3];fbe1={6};fb01=[2 5];
    [xx1,yy1,x1,y1,par1,trainacc,testacc]=expandebls(xadd,xadd1,train_y,test_y,xx,x,time_related1,s,C,h,f1,fo,...
    [],pare1,N1,N2,fe,fe1,nfp,leng,ss,ss1,train_xb1,test_xb1,fb1,fb01,fbe1,obr,obe,ban); 
    subs=plottimes(test_yy,test_y,y1,x1,leng,ss1,[1,0],0,0);
    subjectresultf(k,block).fbls=subs;
    [confusiono_pre1,confusion_pre1,accuracy_pre1,Precidion_pre1,Recall_pre1,Specificity_pre1,F1SCORE_pre1,Kappa_pre1,mcc_pre1]=resultstatsic(y,test_y,n,k);%CCC
    confusiono{k,block}=confusiono_pre1;
    confusion{k,block}=confusion_pre1;
    accuracy{k,block}=accuracy_pre1;
    precision{k,block}=Precidion_pre1;
    recall{k,block}=Recall_pre1;
    specificity{k,block}=Specificity_pre1;
    f1score{k,block}=F1SCORE_pre1;
    kappa{k,block}=Kappa_pre1;
    mcc{k,block}=mcc_pre1;
    Par{k,block}=par1;
%     Pare{k,block}=pare;
    train_acc(k,block)=trainacc;
    test_acc(k,block)=testacc
    mf1(k,block)=mean(F1SCORE_pre1)

    block=12;
    N1=N1(1:4);
%     [xx,yy,x,y,par,leen,trainacc,testacc,tn]=featurebasedbls(fo,f_ex,fe_ex,f0_ex,nfp_ex,[train_x,xx1],[test_x,x1],train_y,test_y,...
%         train_x0,test_x0,leng,s,C,h,par,pare,N1,N2,fe(1:end-1),fe1,ss,ss1);
[xx,yy,x,y,par,trainacc,testacc,tn,train_y]=featurebasedbls(fo,f_ex,fe_ex,f0_ex,nfp_ex,xadd,xadd1,xx1,x1,train_y,test_y,leng,s,C,h,par,pare,N1,N2,fe,fe1,ss,ss1);
    subs=plottimes(test_yy,test_y,y,x,leng,ss1,[1,0],0,0);
    subjectresultf(k,block).fbls=subs;
    [confusiono_pre1,confusion_pre1,accuracy_pre1,Precidion_pre1,Recall_pre1,Specificity_pre1,F1SCORE_pre1,Kappa_pre1,mcc_pre1]=resultstatsic(y,test_y,n,k);%CCC
    confusiono{k,block}=confusiono_pre1;
    confusion{k,block}=confusion_pre1;
    accuracy{k,block}=accuracy_pre1;
    precision{k,block}=Precidion_pre1;
    recall{k,block}=Recall_pre1;
    specificity{k,block}=Specificity_pre1;
    f1score{k,block}=F1SCORE_pre1;
    kappa{k,block}=Kappa_pre1;
    mcc{k,block}=mcc_pre1;
    Par{k,block}=par;
%     Pare{k,block}=pare;
    train_acc(k,block)=trainacc;
    test_acc(k,block)=testacc
    mf1(k,block)=mean(F1SCORE_pre1)
end


disp(add)
for i=1:size(f1score,1)
    ac(i,:)=accuracy{i,block};
    Ka(i,:)=kappa{i,block};
    F1(i,:)=f1score{i,block};
end
disp(['acc of each epoch',num2str(mean(test_acc))])
disp(['mf1 of each epoch',num2str(mean(mf1))])

disp(['acc of last epoch',num2str(mean(ac))])
disp(['f1 of last epoch',num2str(mean(F1))])
disp(['kappa of last epoch',num2str(mean(Ka))])


% f1=zeros(1,kk);f11=zeros(1,kk);f100=zeros(1,5);f10=zeros(1,5);
% for j=1:k
%     for i=1:kk
%         f11(i)=F1SCORE_pre{j,i};
%         f10(i,:)=F1score_pre{j,i};
%     end
%     f1=f1+f11;
%     f100=f100+f10;
% end
% f1=f1/k;
% f100=f100/k;
% [~,fm]=max(f1);
% if size(test_acc,1)~=1
%     accre=mean(test_acc);
% else
%     accre=test_acc;
% end
% [~,acm]=max(accre);
% if fm~=acm
%     ac1=f1*0.7+0.3*accre;
%     [~,acm]=max(ac1);
% end
% accm=acm;
% 
% ACC=zeros(n);
% acc=zeros(1,n);kappa=zeros(1);
% for i=1:k
%     AC1=ACC_pre{i,accm};
%     ac1=accuracy_pre{i,accm};
%     ka1=Kappa_pre{i,accm};
%     ACC=ACC+AC1;
%     acc=acc+ac1;
%     kappa=kappa+ka1;
% end
% ac=accre(accm)
% mF1=f1(accm)
% F1=f100(accm,:)
% ACC=ACC/k
% acc=acc/k
% kappa=kappa/k
% 
% [~,miniter]=min(test_acc(:,1));
% % subjectresult(fit(miniter/2)).fbls;%在结果中使用
% % subjectresult(fit(miniter/2)).tbls;
%  plottimes(Testy{miniter},label2lab(Testy{miniter}),Y{miniter,1},X{miniter,1},leng,sss1{miniter},[1 0],0,1)
% 
% savename=[outdir,'_with_bal_m',num2str(meth),'.mat'];%meth为使用方法类型，可在程序中设置
savename=[outdir,'with_spo2_in_exbls_breathclassifacation','_5_fold_cv.mat'];%meth为使用方法类型，可在程序中设置
save(savename,'test_acc','subjectresultf','confusiono','confusion','accuracy','precision','recall','f1score','kappa','mf1','Par','mcc','leng',...
    'statisosa','test_acc_osa','mf1_osa','f1score_osa','accuracy_osa','kappa_osa','ahiyy','ahiy');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%结果统计%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [group1,group2,group3,group4,groupc,indictg1,indictg2,indictg3,indictg4,indictgc]=groupdat(age,osa,folds)
[~,b]=hist(age,4);o=[0 5 15 30];
for i=1:length(age)
    if age(i)<b(2)
        sub(i,1)=1;
    elseif age(i)<b(3) && age(i)>=b(2)
        sub(i,1)=2;
    elseif age(i)<b(4) && age(i)>=b(3)
        sub(i,1)=3;
    elseif age(i)>b(4)
        sub(i,1)=4;
    end
    if osa(i)<o(2)
        sub(i,2)=1;
    elseif osa(i)<o(3) && osa(i)>=o(2)
        sub(i,2)=2;
    elseif osa(i)<o(4) && osa(i)>=o(3)
        sub(i,2)=3;
    elseif osa(i)>o(4)
        sub(i,2)=4;
    end
end

group1=intersect( find(sub(:,1)==1),find(sub(:,2)==1) );
group2=intersect( find(sub(:,1)==2),find(sub(:,2)==2) );
group3=intersect( find(sub(:,1)==3),find(sub(:,2)==3) );
group4=intersect( find(sub(:,1)==4),find(sub(:,2)==4) );
groupg=[group1;group2;group3;group4];
groupc=setdiff(1:length(osa),groupg);

indictg1=geindict(length(group1),folds);
indictg2=geindict(length(group2),folds);
indictg3=geindict(length(group3),folds);
indictg4=geindict(length(group4),folds);
indictgc=geindict(length(groupc),folds);

end

function indict=geindict(hd,flods)
indict=ones(1,hd);
remk=rem(1:hd,flods);
for i=1:flods
    lk=find(remk==i-1);
    indict(lk)=i;
end
indict=indict';
end

function [ss,ss1,mixsub]=gettrte(group1,group2,group3,group4,groupc,indictg1,indictg2,indictg3,indictg4,indictgc,k,len)
i1=group1(find(indictg1==k));
i2=group2(find(indictg2==k));
i3=group3(find(indictg3==k));
i4=group4(find(indictg4==k));
i5=groupc(find(indictgc==k));
mixsub=setdiff(groupc,i5);
ss1=[i1;i2;i3;i4;i5'];
ss=setdiff(1:len,ss1);
end

function [f,fcon,fb,fb0,fbe,labelb]=norbreattf(Dir)
filename3=[Dir,'_spo2features.mat'];
% filename4=[Dir,'_thermfeatures.mat'];
filename5=[Dir,'_breath_label.mat'];
load(filename3)
% load(filename4)
load(filename5)
fcon=ones(size(SpO2con,1),1);
con=SpO2con;% Thermcon];
s=sum(con')'==2;
fcon(s)=2;
tl=3;
labelb=Labelo30;%Labelo1 Labelo30 Labelb1 Labelb30
labelb(labelb==0)=2;%如果用事件Labelb，这里用3
% %%% spo2 (46)
% % spo2dis=neithbourdis(spo2features(:,[1:3]),tl);
% f=[spo2features(:,[ 1 3:6  9:10 11 14 17 20 12 15 18 21  [23 26 29 32 35 38 41 44] [23 26 29 32 35 38 41 44]+1 ] ) ];
% fspo2=[3 1 1 1 1 4 4  4 1 1 1 1  4 1 1 1 1  ];
% fb=[fspo2];
% fb0=[ 5 6 [5 6]+15  [5 6]+15+8 ];
% fbe={ 1:4 ; [1 3:5]+15 ; [1 3:5]+15+8 };
% %%%%%

%%% spo2 (46)
spo2dis=neithbourdis(spo2features(:,[1:3]),tl);
f=[spo2features(:,[ 1 3:6  9:10 11 14 17 20 12 15 18 21  [23 26 29 32 35 38 41 44] [23 26 29 32 35 38 41 44]+1 ] ) spo2dis];
fspo2=[3 1 1 1 1 4 4  4 1 1 1 1  4 1 1 1 1 (tl*2+1)*ones(1,3) ];
fb=[fspo2];
fb0=[ 5 6 [5 6]+15  [5 6]+15+8 ];
fbe={ 1:4 ; [1 3:5]+15 ; [1 3:5]+15+8 };
%%%%%

% %%% new version(spo2 22 )         spo2+therm
% spo2dis=neithbourdis(spo2features(:,[1:3]),tl);
% thermdis=neithbourdis(thermfeatures(:,13),tl);
% f=[spo2features(:,[ 1 3:6  9:10 11 14 17 20 12 15 18 21]) spo2dis thermfeatures thermdis];%*1.5.*fcon;%(:,[1 3 4 5 7 8 9 11 12 13])
% % f=[spo2features(:,1:5)];
% fspo2=[3 1 1 1 1 4 4 (tl*2+1)*ones(1,3)]; 
% ftherm=[4 4 4 1 (tl*2+1)*ones(1)];
% fb=[fspo2 ftherm];
% sfspo2=sum(fspo2);
% fb0=[5 6 sfspo2+9];
% fbe={1:4;sfspo2+14:sfspo2+16;[1 sfspo2+1 sfspo2+4];[2 sfspo2+2 sfspo2+5];[3 sfspo2+3 sfspo2+6]};
% %%%%%

% %%% old version (spo2 8)     spo2+therm
% spo2dis=neithbourdis(spo2features(:,[1:3]),tl);
% thermdis=neithbourdis(thermfeatures(:,13),tl);
% f=[spo2features(:,1:5) spo2dis thermfeatures thermdis]*1.5.*fcon;%(:,[1 3 4 5 7 8 9 11 12 13])
% % f=[spo2features(:,1:5)];
% fspo2=[4 1 (tl*2+1)*ones(1,3)];
% ftherm=[4 4 4 1 (tl*2+1)*ones(1)];
% fb=[fspo2 ftherm];
% fb0=[5 fspo2+9];
% fbe={1:4;28:30;[1 15 19];[2 16 20];[3 17 21]};
% %%%%%
end

function b=neithbourdis(a,n)
a=[zeros(1,size(a,2));a];
a1=time_causal(a,n,2);
b=diff(a1);
end

function [tr0,nmark]=sub_breath(tr,ss,leng,threshold0)
leng=leng(ss);
for i=1:length(ss)
    k(i) = sum(leng(1:i));
end
k=[0 k];tr0=[];n=0;
for i=1:length(leng)
    tr1=tr(k(i)+1:k(i+1));
    h=length(find(tr1==1));
    threshold=threshold0*length(tr1)/60*2;
    if h>threshold
        n=n+1;
        nmark(n)=i;
        mk=1;
    else
        mk=eps;
    end
    tr0=[tr0;mk*ones(length(tr1),1)];
end
if nmark~=0
   nmark=ss(nmark);
end
end

function [trainacc,testacc,xx1,x1,yy1,y1,par1,con0,train_y,tn]=blsc(add,add1,xx,x,train_y,test_y,s,C,h,fo,f0,par1,pare,N1,N2,fe,fe1,nfp,lengo,ss1)
    [trainacc,traintime,xx1,yy1,par1,con0,train_y,tn] = multi_scale_bls41_grouped(add,add1,xx,x,train_y,test_y,s,C,h,fo,f0,par1,[],1,N1,N2,fe,fe1,[],nfp,[]);
%     leng0=lengo(ss1);
%     leng0=[];
%     for i=1:length(leng01)
%         leng0=[leng0 leng01{i}];
%     end
        leng0=[];
        for lp=1:length(ss1)
            leng0=[leng0 lengo(ss1(lp))];
        end
    for xi=1:length(leng0)
        K0(xi)=sum(leng0(1:xi));
    end
    K0=[0 K0];
    [testacc,testtime,x1,y1,par1,~,~] = multi_scale_bls41_grouped(add,add1,xx,x,train_y,test_y,s,C,h,fo,f0,par1,[],2,N1,N2,fe,fe1,con0,nfp,K0);
    clear K0
    trainacc=trainacc(end);
end


function [trainacc,testacc,xx1,x1,yy1,y1,par1,con0,train_y,tn]=blscb(train_x,train_y,test_x,test_y,s,C,h,fo,f0,par1,pare,N1,N2,fe,fe1,nfp,lengo,ss1)
    [trainacc,traintime,xx1,yy1,par1,con0,train_y,tn] = multi_scale_bls41(train_x,train_y,test_x,test_y,s,C,h,fo,f0,par1,[],1,N1,N2,fe,fe1,[],nfp,[]);
%     leng0=lengo(ss1);
%     leng0=[];
%     for i=1:length(leng01)
%         leng0=[leng0 leng01{i}];
%     end
        leng0=[];
        for lp=1:length(ss1)
            leng0=[leng0 lengo(ss1(lp))];
        end
    for xi=1:length(leng0)
        K0(xi)=sum(leng0(1:xi));
    end
    K0=[0 K0];
    [testacc,testtime,x1,y1,par1,~,~] = multi_scale_bls41(train_x,train_y,test_x,test_y,s,C,h,fo,f0,par1,[],2,N1,N2,fe,fe1,con0,nfp,K0);
    clear K0
    trainacc=trainacc(end);
end
function [trainacc,testacc,xx1,x1,yy1,y1,par1,con0,train_y,tn]=blsc1(train_x,train_y,test_x,test_y,s,C,h,fo,f0,par1,pare,N1,N2,fe,fe1,nfp,lengo,ss1)
    [trainacc,traintime,xx1,yy1,par1,con0,train_y,tn] = multi_scale_bls_breath(train_x,train_y,test_x,test_y,s,C,h,fo,f0,par1,[],1,N1,N2,fe,fe1,[],nfp,[]);
%     leng0=lengo(ss1);
%     leng0=[];
%     for i=1:length(leng01)
%         leng0=[leng0 leng01{i}];
%     end
        leng0=[];
        for lp=1:length(ss1)
            leng0=[leng0 lengo(ss1(lp))];
        end
    for xi=1:length(leng0)
        K0(xi)=sum(leng0(1:xi));
    end
    K0=[0 K0];
    [testacc,testtime,x1,y1,par1,~,~] = multi_scale_bls_breath(train_x,train_y,test_x,test_y,s,C,h,fo,f0,par1,[],2,N1,N2,fe,fe1,con0,nfp,K0);
    clear K0
    trainacc=trainacc(end);
end


function [FF0,f,fe,f0,nfp]=generate_exfeature(FF,time_related,Mode,rep,fo1,para,leng,olen,kl)
ss=1:length(leng);
nrep=rep{2};nfo1=fo1{2};
rep=rep([1 4 ]);fo1=fo1([1 4 ]);Mode=Mode([1 4 ]);%3
FF0=[];f=[];M=[];
cen=ceil(length(para)/2);

for i=1:length(rep)
    time_related1=time_related(i);
    nex=time_related1*2+1;
    Nex(i)=nex;
    m=rep{i};fo=fo1{i};mode=Mode(i);
    FF2=FF(:,m);
    para1=para(cen-time_related1:cen+time_related1);
    [FF1,fex]=matexpand(FF2,time_related1,fo,para1,mode,ss,leng);
    FF0=[FF0 FF1];
    %     train_x2=train_x(:,m);test_x2=test_x(:,m);
    %     [train_x1,fex]=matexpand(train_x2,time_related,fo,para,mode,ss,leng);%需区分分步扩展的和整体扩展的
    %     [test_x1,~]=matexpand(test_x2,time_related,fo,para,mode,ss1,leng);
    %     train_x0=[train_x0 train_x1];test_x0=[test_x0 test_x1];
    f=[f fex];
    fsum(i)=length(f);
    M=[M m];
end
[fe,f0,nfp]=gefeaenhan(f,fsum,Nex(2),olen,kl,2);
fe=[fe];
M1=setdiff(1:size(FF,2),M);
FF0=[FF0 FF(:,M1)];
end

function     [xx,yy,x,y,par,trainacc,testacc,tn,train_y]=featurebasedbls(f1,f,fe,f0,nfp,add,add1,xx,x,...
    train_y,test_y,leng,s,C,h,par,pare,N1,N2,fe0,fe1,ss,ss1)
load(add)
load(add1)
f=[f f1];
fe=[fe sum(f)-5:sum(f)];
K0=[];
[trainacc,testacc,xx,x,yy,y,par,con0,train_y,tn]=blsc(add,add1,xx,x,train_y,test_y,s,C,h,f,f0,par,pare,N1,N2,fe,fe1,nfp,leng,ss1);
% [trainacc,traintime,xx,yy,par,con0,train_y,tn] = multi_scale_bls41_grouped(add,add1,xx,x,train_y,test_y,s,C,h,f,f0,par,pare,1,N1,N2,fe,fe1,[],nfp,[]);
% %     [trainacc,traintime,xx,yy,par,con0,train_y,tn] = recurent_BLS1(train_x,train_y,test_x,test_y,s,C,h,f,f0,par,1,N1,N2,fe,0,nfp,[],1);
% leng0=[];
% for lp=1:length(ss1)
%     leng0=[leng0 leng(ss1(lp))];
% end
% for xi=1:length(leng0)
%     K0(xi)=sum(leng0(1:xi));
% end
% K0=[0 K0];
% [testacc,testtime,x,y,par,~,~] = multi_scale_bls41_grouped(add,add1,xx,x,train_y,test_y,s,C,h,f,f0,par,[],2,N1,N2,fe,fe1,con0,nfp,K0);
% %     [testacc,testtime,x,y,par,~,~,~] = recurent_BLS1(train_x,train_y,test_x,test_y,s,C,h,f,f0,par,2,N1,N2,fe,con0,nfp,K0,1);
% clear K0
% trainacc=trainacc(end);
end

function [C_xr]=xexpan(x,time_related,ss,leng,mode)
gg1=1;gg2=0;
for i=1:length(ss)
    gg=leng((ss(i)));
    gg2=gg2+gg;
    C_xr(gg1:gg2,:)=time_causal(x(gg1:gg2,:),time_related,mode);
    gg1=gg1+gg;
end
end

function [xx1,yy1,x1,y1,par1,trainacc,testacc]=expandebls(add,add1,train_y,test_y,xx,x,time_related,s,C,h,f0,f00,par,pare,N1,N2,fe,fe1,nfp,leng,ss,ss1,train_xb,test_xb,fb,fb0,fbe,obr,obe,ban)
para=[0.6 0.6 0.7 0.7 0.7 0.7 0.75 0.8 0.9 0.95 1 1 0.9 0.85 0.8 0.75 0.7 0.6 0.6 0.6 0.6 0.6 0.6];
sta=(length(para)-(time_related*2)-1)/2;
para=para(sta+1:end-sta);
para=repmat(para,1,5);
% p=[];
% for i=1:length(para)
%     p=[p para(i)*ones(1,5)];
% end
% para=p;
    xtr=time_causal(xx,time_related,2);
    xtr=xtr.*para;
    xte=time_causal(x,time_related,2);
    xte=xte.*para;
%     if ~isempty(obr)
%         nex=time_related*2+1;ob1=[];
%         for i=1:5
%             center=time_related+1+(i-1)*nex;
%             ck=time_related-ban;
%             ob1=[ob1 center-time_related : center-ck-1  center+ck+1 : center+time_related];
%         end
%        xtr(obr,ob1)=xtr(obr,ob1)*0.8;
%        xte(obe,ob1)=xte(obe,ob1)*0.8;
%     end
%     train_x1=[train_x1 xtr];
%     test_x1=[test_x1 xte];
    [fk,fk0,~]=blstimekind(sum(f00)+size(xtr,2),f0);
% %%%%%%呼吸
% %nfp在外层循环已经计算过，因此不需要重新计算，此处仅仅增加对f和f0的计算
if ~isempty(obr)
%     obr1=zeros(size(train_y,1),1);
%     obe1=zeros(size(test_y,1),1);
%     obr1(obr)=1;
%     obe1(obe)=1;
%     train_x1=[train_x1 train_xb.*obr1];
%     test_x1=[test_x1 test_xb.*obe1];
%     train_x1=[train_x1 train_xb];
%     test_x1=[test_x1 test_xb];
    for i=1:length(fbe)
        fbe1=cell2mat(fbe(i))+sum(fk);
        fbe0(i)={fbe1};
    end
    fe=[fe;fbe0';[fe{1} fbe0{1}]];
    fk=[fk fb];
    fk0=[fk0 fb0];
end
%     K0=[];nfp=nfp+length(fb);
[trainacc,testacc,xx1,x1,yy1,y1,par1,con0,train_y,tn]=blsc(add,add1,[xtr train_xb],[xte test_xb],train_y,test_y,s,C,h,fk,fk0,par,pare,N1,N2,fe,fe1,nfp,leng,ss1);
% %%%%%
% [trainacc,traintime,xx,yy,par,con0,train_y,tn] = multi_scale_bls41_grouped(add,add1,xx,x,train_y,test_y,s,C,h,f,f0,par,pare,1,N1,N2,fe,fe1,[],nfp,[]);
% %     [trainacc,traintime,xx,yy,par,con0,train_y,tn] = recurent_BLS1(train_x,train_y,test_x,test_y,s,C,h,f,f0,par,1,N1,N2,fe,0,nfp,[],1);
% leng0=[];
% for lp=1:length(ss1)
%     leng0=[leng0 leng(ss1(lp))];
% end
% for xi=1:length(leng0)
%     K0(xi)=sum(leng0(1:xi));
% end
% K0=[0 K0];
% [testacc,testtime,x,y,par,~,~] = multi_scale_bls41_grouped(add,add1,xx,x,train_y,test_y,s,C,h,f,f0,par,[],2,N1,N2,fe,fe1,con0,nfp,K0);
% %     [testacc,testtime,x,y,par,~,~,~] = recurent_BLS1(train_x,train_y,test_x,test_y,s,C,h,f,f0,par,2,N1,N2,fe,con0,nfp,K0,1);
% clear K0
% trainacc=trainacc(end);
end

function [train_x1,train_x2,test_x1,test_x2]=geset(train_x,test_x,f,rep)
% f=f(1:end-1);rep=setdiff(rep,length(f));
% train_x0=train_x(:,end);test_x0=test_x(:,end);
fk=setdiff(1:length(f),rep);
for i=1:length(f)
    k(i)=sum(f(1:i));
end
k1=ones(1,length(k));
k1(2:end)=k1(2:end)+k(1:end-1);
f1=[];f2=[];
for i=1:length(rep)
    f1=[f1 k1(rep(i)):k(rep(i))];
end
for i=1:length(fk)
    f2=[f2 k1(fk(i)):k(fk(i))];
end
train_x1=[train_x(:,f1) ];
train_x2=[train_x(:,f2) ];
test_x1=[test_x(:,f1) ];
test_x2=[test_x(:,f2) ];
end

function [subjectresultf,ACCo_pre,ACC_pre,accuracy_pre,Precidion_pre,Recall_pre,F1SCORE_pre,F1score_pre,Kappa_pre,...
    Mcc_pre,train_length,trainingacc]=statistic(test_yy,test_y,y,x,leng,ss1,k,kk,n,ACCo_pre,ACC_pre,accuracy_pre,Precidion_pre,Recall_pre,...
    F1SCORE_pre,F1score_pre,Kappa_pre,Mcc_pre,train_length,trainingacc,tn,trainacc)
    subs=plottimes(test_yy,test_y,y,x,leng,ss1,[1,0],0,0);
    subjectresultf(k,kk).fbls=subs;
    clear subs
    train_length(k,kk)=tn;
    trainingacc{k,kk}=trainacc;
    %储存参数，方便后续测试集使用
    [ACCo_pre1,ACC_pre1,accuracy_pre1,Precidion_pre1,Recall_pre1,F1SCORE_pre1,Kappa_pre1,mcc_pre1]=resultstatsic(y,test_y,n,k);%CCC
    ACCo_pre{k,kk}=ACCo_pre1;
    ACC_pre{k,kk}=ACC_pre1;
    accuracy_pre{k,kk}=accuracy_pre1;
    Precidion_pre{k,kk}=Precidion_pre1;
    Recall_pre{k,kk}=Recall_pre1;
    F1SCORE_pre{k,kk}=mean(F1SCORE_pre1);
    F1score_pre{k,kk}=F1SCORE_pre1;
    Kappa_pre{k,kk}=Kappa_pre1;
    Mcc_pre{k,kk}=mcc_pre1;
end

%%%%%%%%%%%%%%%%%%%%%%用于全正特征
function spq=rate_entropy(XX)
b=size(XX,2);
for i=1:b
    p(:,i)=XX(:,i)./sum(XX,2);
end
% q=1-p;
% spq=(p./q).*log(p./q);
spq=p.*log(p);
end

function [c,m0]=find_error(y,test_yy,x)
% test_yy(test_yy==0)=5;
m0=find(y~=test_yy);
k=0;
for i=1:5
    for j=i+1:5
        k=k+1;
        c(:,k)=abs(x(:,i)./x(:,j));
    end
end
end

function [ACC_all_1,ACC_part_1,Accuracy_1,Precidion_1,Recall_1,Specificity_pre1,F1SCORE_1,Kappa_1,Mcc_1]=resultstatsic(y,test_y,n,j)
[Acc_all_1,Acc_part_1,accuracy_1,precision_1,recall_1,specificity_pre1,F1score_1,kappa_1,mcc_1] = Evaluation(y,test_y,n);
ACC_all_1=Acc_all_1;%ACC是总体百分比
ACC_part_1=Acc_part_1;%ACC每一项是百分比
Accuracy_1=accuracy_1;
Precidion_1=precision_1;
Recall_1=recall_1;
Specificity_pre1=specificity_pre1;
F1SCORE_1=F1score_1;
Kappa_1=kappa_1;
Mcc_1=mcc_1;
end

function fe=othersignal(da)
da1=da(da<quantile(da,0.9));
me1=mean(da1);
me=mean(da);
if me/me1>6
    da=da1;
    da(da>quantile(da,0.9))=quantile(da,0.9);
end
da=da-mean(da);
s=diff(da>0);
l1=length(find(s==1));
l2=length(find(s==-1));
zc=l1+l2;
st=std(da1);
mea=median(da1);
fe=[me mea st zc];
end

function [train_x,test_x,endpoint]=retrainset(kk,train_x,test_x,leen,x_tr,x_te,tl,mode,cr1,ce1)
% tl=2;
% mode=2;
endpoint=tl*mode*5+5;
% corra=[1 1 1 1 1];
a1=0.15;a2=a1-0.1;
s=1:-a1:1-a1*tl;
if mode==1
    s=sort(s);
else
    s1=sort(s)+a2;
    s=[s1(1:end-1) s];
end
ls=endpoint/5;
s0=[];
% for i=1:ls
%     s0=[s0 s(i)*ones(1,5)];
% end
s0=repmat(s,1,tl*mode+1);
xtr=time_causal(zscore((x_tr.*cr1)')',tl,mode);
xte=time_causal(zscore((x_te.*ce1)')',tl,mode);
xtr=xtr.*s0;
xte=xte.*s0;
% if mo==1
%     train_x=[train_x xtr];
%     test_x=[test_x xte];
% else
if kk==1
    train_x(:,leen+1:leen+endpoint)=xtr;
    test_x(:,leen+1:leen+endpoint)=xte;
else
    train_x(:,leen+1:leen+endpoint)=(train_x(:,leen+1:leen+endpoint)+xtr)/2;
    test_x(:,leen+1:leen+endpoint)=(test_x(:,leen+1:leen+endpoint)+xte)/2;
end
%     [train_x, test_x]=pre_zca(train_x,test_x);

%         train_x(:,leen+1:leen+endpoint)=xtr;test_x(:,leen+1:leen+endpoint)=xte;
%         %     train_x=[train_x x_tr];test_x=[test_x x_te];
%     else
%         %     x=CCC(kk)/CCC(kk-1);
%         %     x=2^x;
%         xtr1=x_tr./corra;
%         xte1=x_te./corra;
%         train_x(:,leen+1:leen+endpoint+5)=[xtr xtr1];test_x(:,leen+1:leen+endpoint+5)=[xte xte1];
%         %     train_x=[train_x x_tr./corra];test_x=[test_x x_te./corra];
%     end
% end
end

function [fe,f0,nfp]=gefeaenhan(fo,fsum,m,olen,kl,t)
%仅针对ft进行多导信号同步  olen原始眼电通道长度  kl眼电单位系数  t需要扩展的特征种类
n=olen/(6/kl);%特征种类数
f=[fsum(t-1) fsum(t)];
for i=1:length(fo)
    fs(i)=sum(fo(1:i));
end
f=fs(f(1))+1:fs(f(2));
bu=length(f)/m/olen;%bu<2 EEG+EOG kl>1     bu==2 EEG+EOG  kl==1   or   EEG+EOG+EMG  kl==2
%bu==3 EEG*2 EOG*2  kl==2

fet=f(1:m*olen*kl);
fot=f(m*olen*kl+1:m*olen*(kl+1));
% if bu>=3
%    fmt=f(m*olen*(kl+1)+1:end);
% end
d=1;%取多长时间的脑电眼电同步信号，取1为10s，取2为20s，取3为30s
olp=rem(6,d*kl);
for i=1:olen*m/d
    % ften0=[fet(6*(i-1)+1:6*i) fot(6/kl*(i-1)+1:6/kl*i)];
    fet1=fet(d*kl*(i-1)+1 - (i-1)*olp : d*kl*i - (i-1)*olp);
    fot1=fot(d*(i-1)+1:d*i);
    fe{i}=[fet1 fot1];
end
% % f0=[6:14 64:84]+(m-1)/2*sum(fo(1:fsum(1)))/m;

f0=[12:18 221:247]+(m-1)/2*sum(fo(1:fsum(1)))/m;
nfp=length(fo)-length(fo);
end

function [f,f0,nfp]=blstimekind(len,f1)
f=[f1 5*ones(1,(len-sum(f1))/5)];% 以5为单位
nfp=(len-sum(f1))/5;
% f=[f1 (len-sum(f1))/5*ones(1,5)];% 以tl*2+1为单位
% if ((len-sum(f1))/5)
%     nfp=(len-sum(f1))/((len-sum(f1))/5);
% else
%     nfp=0;
% end
if nfp
    f0=[6:14 64:84 sum(f1):sum(f)];
else
    f0=[6:14 64:84];
end

    
end

% function [f,f0,nfp]=blstimekind(len,f1,rep,n,mode,f2)
% %%%%%rep part
% f10=f1(rep(1:end-1));
% f20=f1(rep(end));%f1(setdiff(1:length(f1),rep));
% if mode==1
%     f1rep=repmat(f10,1,n);
% else
%     f1rep=[];
%     for i=1:length(rep)-1
%         f1r=repmat(f10(i),1,n);
%         f1rep=[f1rep f1r];
%     end
% end
% 
% % f=[f1 5*ones(1,(len-sum(f1))/5)];%增加的 c
% f=[f1rep f20 f2];
% 
% f0=[6:14 64:84]+(n-1)/2*sum(f10);
% nfp=len-sum(f1rep);
% % % if length(f)>len
% % %     f0=[6:10 length(f1)+1];
% % % else
% %     f0=[6:14 64:84];
% % % end
% %     nfp=(len-sum(f1))/5;
% end

function [Label,leng,X]=increasesstages(label,stage,x,mark,leng,si)
len1=[];X=[];Label=[];l1=1;l2=0;
for i=1:length(si)
    le=leng(si(i));
    l2=l2+le;
    label1=label(l1:l2);
    x1=x(l1:l2,:);
    [label1,h0,len,s]=increasedata(label1,stage);
    if ~isempty(s)
        x1=fixdata(x1,h0,s,mark);
    end
    Label=[Label;label1];
    len1=[len1 len];
    X=[X;x1];
    clear x1 len label1
    l1=l1+le;
end
leng(si)=len1;
end

function [train_x,train_y,train_yy,leng1,dimarks]=samplebalance(train_x,train_yy,len1,leng,ss)
mark=setdiff(1:size(train_x,2),[80:100]);
%     mark=1:size(train_x,2);
train_x=[train_x zeros(len1,1)];
leng1=leng;
m1=[1 3 5];
m2=[0.05 0.15 0.15];
k=0;
for i=1:length(m1)
    if length(find(train_yy==m1(i)))/length(train_yy)<m2(i)
        k=k+1;
        mk(k)=m1(i);
    end
end
if ~isempty(mk)
    for i=1:length(mk)
        [train_yy,leng1,train_x]=increasesstages(train_yy,mk(i),train_x,mark,leng1,ss);
    end
end
dimark=find(train_x(:,end)==1);
dimarks=setdiff(1:length(train_x),dimark);
train_x=train_x(:,1:end-1);
train_y=label2lab(train_yy);
end

function [X1,X2,LABEL,leng1]=banwake(X,X0,Label,leng,b)
l1=1;l2=0;X1=[];X2=[];LABEL=[];leng1=[];
for i=1:length(leng)
    le=leng(i);
    l2=l2+le;
    x=X(l1:l2,:);
    x1=X0(l1:l2,:);
    label=Label(l1:l2);
    n1=length(find(label==2))/length(label);
    n2=length(find(label==5))/length(label);
    if n2>n1 || n2>0.5
        m1=find(label~=5,1);
        m2=find(label~=5,1,'last');
        %         m=find(label==5);
        %         s=randperm(length(m));
        %         s1=s(1:floor(length(s)/5));
        s1=1:ceil(m1*b);
        s20=length(label)-m2;
        s2=floor(m2+s20*(1-b)):length(label);
        dimark=setdiff(1:size(x,1),union(s1,s2));
        x=x(dimark,:);
        x1=x1(dimark,:);
        label=label(dimark);
    end
    len1=length(label);
    X1=[X1;x];
    X2=[X2;x1];
    LABEL=[LABEL;label];
    leng1=[leng1;len1];
    l1=l1+le;
end
end

function [train_y00,study_rate,si]=trainybanlance1(kk,train_x,train_yy,train_y,study_rate,xx,yy,cr1,train_y0,con_st,si,ss,ko0)
train_y00=[];
for bo=1:length(ss)
    trainy=train_y(ko0(bo)+1:ko0(bo+1),:);
    trainx=train_x(ko0(bo)+1:ko0(bo+1),:);
    trainyy=train_yy(ko0(bo)+1:ko0(bo+1));
    if size(train_y0,1)==size(train_yy,1)
        trainy0=train_y0(ko0(bo)+1:ko0(bo+1));
    else
        trainy0=train_y0;
    end
    xx0=xx(ko0(bo)+1:ko0(bo+1),:);
    yy0=yy(ko0(bo)+1:ko0(bo+1),:);
    cr10=cr1(ko0(bo)+1:ko0(bo+1));
    [trainy,study_rate,si]=trainybanlance(kk,trainx,trainyy,trainy,study_rate,xx0,yy0,cr10,trainy0,con_st,si);
    train_y00=[train_y00;trainy];
end
end

function [linearModel, x, y ,MAE, RMSE,tr0,te0] = osares(leng,ss,ss1,yy20,y20,osacha)
[train_x,train_y]=geosada(leng,ss,yy20,osacha);
[test_x,test_y]=geosada(leng,ss1,y20,osacha);
linearModel = fitlm(train_x, train_y,'interactions', 'RobustOpts', 'logistic');%'linear'     'logistic'
x=predict(linearModel,train_x);
y=predict(linearModel,test_x);
MAE=mean(test_y-y);
RMSE=sqrt(abs(sum(test_y-y).^2));
tr=x>=15;te=y>=15;
[tr0]=osasub(leng,ss,tr);
[te0]=osasub(leng,ss1,te);
end

function [tr0]=osasub(leng,ss,tr)
leng=leng(ss);
for i=1:length(ss)
    k(i) = sum(leng(1:i));
end
k=[0 k];tr0=[];n=0;
for i=1:length(leng)
    if tr(i)
        n=n+1;
        nmark(n)=i;
    else
        tr0=[tr0 k(i)+1:k(i+1)];
    end
end
end

function [osadatr,osatr]=geosada(leng,ss,yy20,osacha)
k=0;lengss=leng(ss);
for i=1:length(ss)
k(i)=sum(lengss(1:i));
end
k=[0 k];
for i=1:length(ss)
da=yy20(k(i)+1:k(i+1));
osadatr(i,1)=length(find(da==1))/length(da);
osadatr(i,2)=length(find(da==2))/length(da);
osadatr(i,3)=length(find(diff(da)~=0))/length(da);
osadatr(i,4)=length(find(diff(da)==0))/length(da);
end
osatr=osacha(ss);
end

function [statistic]=osasta(a,b)
n=[0 5 15 30];
a1=ones(size(a,1),1);
b1=ones(size(b,1),1);
for i=1:length(n)-1
    n1=n(i);n2=n(i+1);
    a1(intersect(find(a>=n1),find(a<n2)))=(i+1);
    b1(intersect(find(b>=n1),find(b<n2)))=(i+1);
end
    ac=length(find(a1==b1))/length(a1);
    [con,Acc_part_1,accuracy_1,precision_1,recall_1,specificity_1,F1score_1,kappa_1,mcc_1] = Evaluation(a1,label2lab(b1),4);
    statistic.ahi=n;
    statistic.acc=ac;
    statistic.recall=recall_1;
    statistic.specificity=specificity_1;
    statistic.confusion=con;
    statistic.f1=F1score_1;
    statistic.mf1=mean(F1score_1);
    statistic.kappa=kappa_1;
end

function [N1,N2,fe,fe1]=trainparosa(b,tur,kk,ten,time_related)
%tur 为判断是timebls 还是 featurebls
n=6;
b1=ceil(b/n);
unit=time_related*2+1;
% a=141:176;a1=177:194;%对应脑电，眼电的t
% for i=1:length(a1)
%     x{i,1}=[a((i-1)*2+1:i*2) a1(i)];
% end
if tur==1
    N1=[1 ceil(b1/12)  ceil(b1/6)  ceil(b1/4)  ceil(b1/3) ];% acc 85.7  mf1 79.38
%      N1=[ ceil(b1/12)  ceil(b1/6)  ceil(b1/4) ceil(b1/3) ceil(b1/12) ]; %acc 84.92
%     N1=[1 ceil(b1/12)  ceil(b1/6)  ceil(b1/3)];
%       N1=[ceil(b1/12) ceil(b1/12) ceil(b1/12) ceil(b1/12) ceil(b1/12) ceil(b1/12)];
%     N1=[1 ceil(b1/12)  ceil(b1/6)  ceil(b1/6) ceil(b1/6)  ceil(b1/3)];
    N2=1;
    if kk>=2
%         b1=b1*n;
          fe={[1:6 7:12];[33:62];[63:68 69:74];[b+1:b+ten]};
%         7:12];[62:67];[68:74];[220:228];[b+1:b+ten]};%[220:228]  acc85.86
%         fe1={time_related+1+unit*([1:5]-1)};
          fe1={[6 17 28 39 50]};
    else
%         fe={[1:6 7:12];[62:67];[68:74];[220:228]};
        fe={[1:6 7:12];[33:62];[63:68 69:74]};
        fe1={};
    end
%     fe=[fe ; x];
%     fe={};
%     fe1={};
else
%     b=ceil(b/n);
    N1=[1 ceil(b1/12) ceil(b1/6)  ceil(b1/6) ceil(b1/6)  ceil(b1/3)];
    N2=1;%[1 1 2]
    fe={1:5*(time_related*2+1)};
    fe1={1:unit*5};
% fe={};
% fe1={};
end
end

function [train_x,test_x,endpoint]=retrainsetosa(kk,train_x,test_x,leen,x_tr,x_te,tl,mode)
nl=size(x_tr,2);
endpoint=tl*2*nl+nl;

xtr=time_causal(x_tr,tl,mode);
xte=time_causal(x_te,tl,mode);


% if kk<=2
    train_x(:,leen+1:leen+endpoint)=xtr;
    test_x(:,leen+1:leen+endpoint)=xte;
% else
%     train_x(:,leen+1:leen+endpoint)=(train_x(:,leen+1:leen+endpoint)+xtr)/2;
%     test_x(:,leen+1:leen+endpoint)=(test_x(:,leen+1:leen+endpoint)+xte)/2;
% end

end

function [f,f0,fe,nfp]=blstimekindosa(len,f1,fe)
f=[f1 2*ones(1,(len-sum(f1))/2)];%增加的 c
if length(f)>len
    f0=[1:5 10:15 sum(f1):len];
else
    f0=[1:5 10:15];
end
    nfp=(len-sum(f1))/2;
    fe=[fe;sum(f1):len];
end

function [trainacc,testacc,yy20,y20,xx20,x20,cono_1,con_1,acc_1,pre_1,rec_1,sp_1,f1_1,ka_1,mc_1,mae,rmse,ybro,ybeo,...
    statisticosa,ofb1,train_xb,test_xb]...
    =blsosa(train_xb,test_xb,train_y1,test_y1,x_tr0,x_te0,yy1,y1,leng,s,C,h,ss,ss1,osacha,block1,N1b,N2b,ofb,ofbe)
xx01=zeros(size(yy1,1),2);x01=zeros(size(y1,1),2);
xx01(find(yy1==5),2)=1;xx01(find(yy1~=5),1)=1;
x01(find(y1==5),2)=1;x01(find(y1~=5),1)=1;
train_xb=[train_xb xx01];test_xb=[test_xb x01];
[train_xb,test_xb,ten]=retrainsetosa(block1,train_xb,test_xb,size(train_xb,2)-size(xx01,2),x_tr0,x_te0,2,2);
[ofb1,ofb01,ofbe1,nfpb1]=blstimekindosa(size(train_xb,2),ofb,ofbe);
[trainacc,testacc,xx20,x20,yy20,y20,~,con0,~,tn]=blsc1(train_xb,train_y1,test_xb,test_y1,s,C,h,ofb1,ofb01,[],[],N1b,N2b,ofbe1,[],nfpb1,leng,ss1);
[cono_1,con_1,acc_1,pre_1,rec_1,sp_1,f1_1,ka_1,mc_1] = Evaluation(y20,test_y1,2);
[~, ~, yo ,mae, rmse,ybro,ybeo] = osares(leng,ss,ss1,yy20,y20,osacha);
[statisticosa]=osasta(yo,osacha(ss1));
end
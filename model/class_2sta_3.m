function [x_tr,x_te,y_tr,y_te,PAR,train_y]=class_2sta_3(y,yy,y_tr,y_te,x_tr,x_te,C_train_x,train_y,C_test_x,test_y,s,C,h,time_related,f,f0,PAR,N1,N2,fe,fe1,cr1,ce1,con_st)
[~,~,~,~,~,~,~,~,de_s,de_l,dr_s,dr_l]=gain_time_set(C_test_x,C_train_x,y,yy,test_y,train_y,cr1,ce1,con_st);
% [con,dcon]=conlabel(y,[]);%连续与非连续
% le_hs=intersect(de_l,con);
% le_hd=intersect(de_l,dcon);
% le_ls=intersect(de_s,con);
% le_ld=intersect(de_s,dcon);
% clear con dcon
% [con,dcon]=conlabel(yy,[]);%连续与非连续
% lr_hs=intersect(dr_l,con);
% lr_hd=intersect(dr_l,dcon);
% lr_ls=intersect(dr_s,con);
% lr_ld=intersect(dr_s,dcon);%union(con,dcon)
le_hs=de_l(y(de_l)==y_te(de_l));
le_hd=de_l(y(de_l)~=y_te(de_l));%阈值较大且不等
le_ls=de_s(y(de_s)==y_te(de_s));
le_ld=de_s(y(de_s)~=y_te(de_s));

lr_hs=dr_l(yy(dr_l)==y_tr(dr_l));
lr_hd=dr_l(yy(dr_l)~=y_tr(dr_l));
lr_ls=dr_s(yy(dr_s)==y_tr(dr_s));
lr_ld=dr_s(yy(dr_s)~=y_tr(dr_s));
%%%%%看是否可添加条件，使标签连续的较小置信度样本分在一组
tt=1:size(C_train_x,2);
f1=f(1:5);
[C_xr,C_xe]=weight_Ctrain(C_train_x(lr_hs,1:sum(f1)),C_test_x(le_hs,1:sum(f1)),time_related,1);
% [C_xr,C_xe]=newtime(C_xr,C_xe,time_related,tt);
[par_hs,pare_hs,par_hd,pare_hd,par_lsl,pare_lsl,par_lss,pare_lss,par_ld,pare_ld]=repar(PAR);
% [~,~,xx_hs,yy_hs,par_hs,pare_hs,con0] = multi_scale_bls3(C_xr,train_y(lr_hs,:),C_xe,test_y(le_hs,:),s,C,h,f1,f0,par_hs,pare_hs,1,N1,N2,fe,fe1,[]);
% [~,~,x_hs,y_hs,~,~,~] = multi_scale_bls3(C_xr,train_y(lr_hs,:),C_xe,test_y(le_hs,:),s,C,h,f1,f0,par_hs,pare_hs,2,N1,N2,fe,fe1,con0);
[~,~,xx_hs,yy_hs,par_hs,con0,train_yhs] = multi_scale_bls4(C_xr,train_y(lr_hs,:),C_xe,test_y(le_hs,:),s,C,h,f1,f0,par_hs,pare_hs,1,N1,N2,fe,fe1,[],0);
[~,~,x_hs,y_hs,~,~,] = multi_scale_bls4(C_xr,train_y(lr_hs,:),C_xe,test_y(le_hs,:),s,C,h,f1,f0,par_hs,pare_hs,2,N1,N2,fe,fe1,con0,0);
%     xx_hs=x_tr(lr_hs,:);x_hs=x_te(le_hs,:);
%     yy_hs=y_tr(lr_hs);y_hs=y_te(le_hs);

if length(lr_hd)>=1000 && length(le_hd)>=1000 && length(le_hd)>length(lr_hd)
    [C_xr,C_xe]=weight_Ctrain(C_train_x(lr_hd,:),C_test_x(le_hd,:),time_related,1);
    [C_xr,C_xe]=newtime(C_xr,C_xe,time_related,tt);
%     [~,~,~,~,x_hd,xx_hd,y_hd,yy_hd] = multibls_t(C_xr,train_y(lr_hd,:),C_xe,test_y(le_hd,:),s,C,9,CC,h1,f,f0);
    
% [~,~,xx_hd,yy_hd,par_hd,pare_hd,con0] = multi_scale_bls3(C_xr,train_y(lr_hd,:),C_xe,test_y(le_hd,:),s,C,h,f,f0,par_hd,pare_hd,1,N1,N2,fe,fe1,[]);
% [~,~,x_hd,y_hd,~,~,~] = multi_scale_bls3(C_xr,train_y(lr_hd,:),C_xe,test_y(le_hd,:),s,C,h,f,f0,par_hd,pare_hd,2,N1,N2,fe,fe1,con0);
[~,~,xx_hd,yy_hd,par_hd,con0,train_yhd] = multi_scale_bls4(C_xr,train_y(lr_hd,:),C_xe,test_y(le_hd,:),s,C,h,f,f0,par_hd,pare_hd,1,N1,N2,fe,fe1,[],0);
[~,~,x_hd,y_hd,~,~,] = multi_scale_bls4(C_xr,train_y(lr_hd,:),C_xe,test_y(le_hd,:),s,C,h,f,f0,par_hd,pare_hd,2,N1,N2,fe,fe1,con0,0);
else
    train_yhd=train_y(lr_hd,:);
    xx_hd=x_tr(lr_hd,:);x_hd=x_te(le_hd,:);
    yy_hd=y_tr(lr_hd);y_hd=y_te(le_hd);
end

[C_xr,C_xe]=weight_Ctrain(C_train_x(lr_ls,:),C_test_x(le_ls,:),time_related,1);
[C_xr,C_xe]=newtime(C_xr,C_xe,time_related,tt);%
[y_ls,yy_ls,x_ls,xx_ls,par_lsl,pare_lsl,par_lss,pare_lss,train_yls]=gain_time_set_p(C_xe,C_xr,y(le_ls),yy(lr_ls),test_y(le_ls,:),train_y(lr_ls,:),s,C,h,f,f0,par_lsl,pare_lsl,par_lss,pare_lss,N1,N2,fe,fe1);

% [~,Test_accuracy_ls,~,~,x_ls,xx_ls,y_ls,yy_ls] = multibls_t(C_xr,train_y(lr_ls,:),C_xe,test_y(le_ls,:),s,C,9,CC,h1);

if length(lr_ld)>=1000 && length(le_ld)>=1000 && length(le_ld)<length(lr_ld)
    [C_xr,C_xe]=weight_Ctrain(C_train_x(lr_ld,:),C_test_x(le_ld,:),time_related,1);
    [C_xr,C_xe]=newtime(C_xr,C_xe,time_related,tt);
%     [~,~,~,~,x_ld,xx_ld,y_ld,yy_ld] = multibls_t(C_xr,train_y(lr_ld,:),C_xe,test_y(le_ld,:),s,C,9,CC,h1,f,f0);
    
% [~,~,xx_ld,yy_ld,par_ld,pare_ld,con0] = multi_scale_bls3(C_xr,train_y(lr_ld,:),C_xe,test_y(le_ld,:),s,C,h,f,f0,par_ld,pare_ld,1,N1,N2,fe,fe1,[]);
% [~,~,x_ld,y_ld,~,~,~] = multi_scale_bls3(C_xr,train_y(lr_ld,:),C_xe,test_y(le_ld,:),s,C,h,f,f0,par_ld,pare_ld,2,N1,N2,fe,fe1,con0);
[~,~,xx_ld,yy_ld,par_ld,con0,train_yld] = multi_scale_bls4(C_xr,train_y(lr_ld,:),C_xe,test_y(le_ld,:),s,C,h,f,f0,par_ld,pare_ld,1,N1,N2,fe,fe1,[],0);
[~,~,x_ld,y_ld,~,~,] = multi_scale_bls4(C_xr,train_y(lr_ld,:),C_xe,test_y(le_ld,:),s,C,h,f,f0,par_ld,pare_ld,2,N1,N2,fe,fe1,con0,0);
else
    train_yld=train_y(lr_ld,:);
    xx_ld=x_tr(lr_ld,:);x_ld=x_te(le_ld,:);
    yy_ld=y_tr(lr_ld);y_ld=y_te(le_ld);
end

y_te=rank_yy(y_hs,le_hs,y_hd,le_hd,y_ls,le_ls,y_ld,le_ld);
y_tr=rank_yy(yy_hs,lr_hs,yy_hd,lr_hd,yy_ls,lr_ls,yy_ld,lr_ld);
x_te=rank_xx(x_hs,le_hs,x_hd,le_hd,x_ls,le_ls,x_ld,le_ld);
x_tr=rank_xx(xx_hs,lr_hs,xx_hd,lr_hd,xx_ls,lr_ls,xx_ld,lr_ld);
train_y=rank_xx(train_yhs,lr_hs,train_yhd,lr_hd,train_yls,lr_ls,train_yld,lr_ld);
PAR=gepar(par_hs,pare_hs,par_hd,pare_hd,par_lsl,pare_lsl,par_lss,pare_lss,par_ld,pare_ld);
end

function PAR=gepar(par_hs,pare_hs,par_hd,pare_hd,par_lsl,pare_lsl,par_lss,pare_lss,par_ld,pare_ld)
PAR.hs=par_hs;
PAR.hse=pare_hs;
PAR.hd=par_hd;
PAR.hde=pare_hd;
PAR.ls1=par_lsl;
PAR.ls2=par_lss;
PAR.lse1=pare_lsl;
PAR.lse2=pare_lss;
PAR.ld=par_ld;
PAR.lde=pare_ld;
end

function [par_hs,pare_hs,par_hd,pare_hd,par_lsl,pare_lsl,par_lss,pare_lss,par_ld,pare_ld]=repar(PAR)
if isempty(PAR)
    par_hs=[];
    pare_hs=[];
    par_hd=[];
    pare_hd=[];
    par_lsl=[];
    par_lss=[];
    pare_lsl=[];
    pare_lss=[];
    par_ld=[];
    pare_ld=[];
else
    par_hs=PAR.hs;
    pare_hs=PAR.hse;
    par_hd=PAR.hd;
    pare_hd=PAR.hde;
    par_lsl=PAR.ls1;
    par_lss=PAR.ls2;
    pare_lsl=PAR.lse1;
    pare_lss=PAR.lse2;
    par_ld=PAR.ld;
    pare_ld=PAR.lde;
end
end


function y_4=rank_yy(y_hs,le_hs,y_hd,le_hd,y_ls,le_ls,y_ld,le_ld)
u01=[y_hs,le_hs];
u02=[y_hd,le_hd];
u03=[y_ls,le_ls];
u04=[y_ld,le_ld];
y=sortrows([u01;u02;u03;u04],2);
y_4=y(:,1);
end

function y_4=rank_xx(y_hs,le_hs,y_hd,le_hd,y_ls,le_ls,y_ld,le_ld)
u01=[y_hs,le_hs];
u02=[y_hd,le_hd];
u03=[y_ls,le_ls];
u04=[y_ld,le_ld];
y=sortrows([u01;u02;u03;u04],6);
y_4=y(:,1:5);
end


function [C_train_x,C_test_x]=newtime(C_train_x,C_test_x,time_related,tt)%形成和之前不同的train——time
%%%%%形成新的时间关系
x=C_test_x(:,26:30);
xx=C_train_x(:,26:30);
x=time_causal(x,time_related,2);
xx=time_causal(xx,time_related,2);
C_train_x=[C_train_x(:,tt) xx];
C_test_x=[C_test_x(:,tt) x];
%%%%%%%%%%%%%%%%%%%
end

function [y_ls,yy_ls,x_ls,xx_ls,par_l,pare_l,par_s,pare_s,train_yls]=gain_time_set_p(C_test_x,C_train_x,y,yy,test_y,train_y,s,C,h,f,f0,par_l,pare_l,par_s,pare_s,N1,N2,fe,fe1)
    %%%%%%%%%  l is the right part of data
    %%%%%%%%%  s is the wrong part of data
%     de_l=find(test_yy==y);de_s=find(test_yy~=y);
%     dr_l=find(train_yy==yy);dr_s=find(train_yy~=yy);

    [cony_e,chany_e,insy_e]=check_stages_kind(y,10,5,0.8);
    [cony_r,chany_r,insy_r]=check_stages_kind(yy,10,5,0.8);
    
    chany_e=[chany_e insy_e];
    chany_r=[chany_r insy_r];
    
    C_test_x_l=C_test_x(cony_e,:);
    C_test_x_s=C_test_x(chany_e,:);
%     C_test_x_m=C_test_x(insy_e,:);
    C_train_x_l=C_train_x(cony_r,:);
    C_train_x_s=C_train_x(chany_r,:);
%     C_train_x_m=C_train_x(insy_r,:);


    lab_te_l=test_y(cony_e,:);
    lab_te_s=test_y(chany_e,:);
%     lab_te_m=test_y(insy_e,:);
    lab_tr_l=train_y(cony_r,:);
    lab_tr_s=train_y(chany_r,:);
%     lab_tr_m=train_y(insy_r,:);
    
%     [~,~,xx_l,yy_l,par_l,pare_l,con0] = multi_scale_bls3(C_train_x_l,lab_tr_l,C_test_x_l,lab_te_l,s,C,h,f,f0,par_l,pare_l,1,N1,N2,fe,fe1,[]);
%     [~,~,x_l,y_l,~,~,~] = multi_scale_bls3(C_train_x_l,lab_tr_l,C_test_x_l,lab_te_l,s,C,h,f,f0,par_l,pare_l,2,N1,N2,fe,fe1,con0);
    
[~,~,xx_l,yy_l,par_l,con0,lab_tr_l] = multi_scale_bls4(C_train_x_l,lab_tr_l,C_test_x_l,lab_te_l,s,C,h,f,f0,par_l,pare_l,1,N1,N2,fe,fe1,[],0);
[~,~,x_l,y_l,~,~] = multi_scale_bls4(C_train_x_l,lab_tr_l,C_test_x_l,lab_te_l,s,C,h,f,f0,par_l,pare_l,2,N1,N2,fe,fe1,con0,0);
    
%     [~,~,xx_s,yy_s,par_s,pare_s,con0] = multi_scale_bls3(C_train_x_s,lab_tr_s,C_test_x_s,lab_te_s,s,C,h,f,f0,par_s,pare_s,1,N1,N2,fe,fe1,[]);
%     [~,~,x_s,y_s,~,~,~] = multi_scale_bls3(C_train_x_s,lab_tr_s,C_test_x_s,lab_te_s,s,C,h,f,f0,par_s,pare_s,2,N1,N2,fe,fe1,con0);
    
[~,~,xx_s,yy_s,par_s,con0,lab_tr_s] = multi_scale_bls4(C_train_x_s,lab_tr_s,C_test_x_s,lab_te_s,s,C,h,f,f0,par_s,pare_s,1,N1,N2,fe,fe1,[],0);
[~,~,x_s,y_s,~,~] = multi_scale_bls4(C_train_x_s,lab_tr_s,C_test_x_s,lab_te_s,s,C,h,f,f0,par_s,pare_s,2,N1,N2,fe,fe1,con0,0);
%     [~,~,~,~,x_m,xx_m,y_m,yy_m] = multibls_t(C_train_x_m,lab_tr_m,C_test_x_m,lab_te_m,s,C,9,CC,h1);
    


    y_ls=rank_y2(y_s,chany_e,y_l,cony_e);
    yy_ls=rank_y2(yy_s,chany_r,yy_l,cony_r);
    x_ls=rank_y2(x_s,chany_e,x_l,cony_e);
    xx_ls=rank_y2(xx_s,chany_r,xx_l,cony_r);
    train_yls=rank_y2(lab_tr_s,chany_r,lab_tr_l,cony_r);
%     y_ls=rank_y1(y_s,chany_e,y_l,cony_e,y_m,insy_e);
%     yy_ls=rank_y1(yy_s,chany_r,yy_l,cony_r,yy_m,insy_r);
%     x_ls=rank_y1(x_s,chany_e,x_l,cony_e,x_m,insy_e);
%     xx_ls=rank_y1(xx_s,chany_r,xx_l,cony_r,xx_m,insy_r);
end
%%%%%%%%%%%%%%先运行，看结果，再决定暑促什么
function y_2=rank_y1(y_s,chany_e,y_l,cony_e,y_m,insy_e)
y_s1=[y_s chany_e'];%%%%%%%%%%%%%%第二次的y_s
y_l1=[y_l cony_e'];
y_m1=[y_m insy_e'];
y_2=sortrows([y_l1;y_s1;y_m1],size(y_s1,2));%%有对高置信度操作时，y_l0改为y_l1
y_2=y_2(:,1:end-1);
end
function y_2=rank_y2(y_s,de_s,y_l,de_l)
de_s=pard(de_s);
de_l=pard(de_l);
    y_s1=[y_s de_s];%%%%%%%%%%%%%%第二次的y_s
    y_l1=[y_l de_l];
%     y_m1=[y_m de_m];
%     y_2=sortrows([y_l1;y_m1;y_s1],2);%%有对高置信度操作时，y_l0改为y_l1
    y_2=sortrows([y_l1;y_s1],size(y_s1,2));%%有对高置信度操作时，y_l0改为y_l1
    y_2=y_2(:,1:end-1);
%     yy_21=sortrows([y_l0;y_s1(:,1:2)],2);
%     yy_21=yy_21(:,1);
end
function [a]=pard(a)
[m1,n1]=size(a);
if m1<n1
    a=a';
end
end
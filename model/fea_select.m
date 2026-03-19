function [FF,index,phis,F2]=fea_select(FF,label,f,n,t)

[phis,index]=mrMr(FF,label);
s=quantile(phis,1-n);
mark=phis>s;
phis=phis(mark);
index=index(mark);
[phis,mark1]=sort(phis,'descend');
index=index(mark1);

for i=1:length(f)
    F(i)=sum(f(1:i));
end
F=[0 F];
for i=1:length(F)-1
    F1=F(i)+1:F(i+1);
    ph=intersect(F1,index);
    F2(i)=length(ph);
end
F2=F2(F2~=0);
if t==0%在最开始进行特征选择
F2=[F2 1];
end
index=sort(index);
FF=FF(:,index);


end
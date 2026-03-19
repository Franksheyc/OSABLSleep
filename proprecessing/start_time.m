tic
objDir='D:\database\MASS\Base_annotations\SS';
outputDir = 'D:\database\MASS\';
num1=[1,2,3,4,5];
len1=[53,19,64,40,26];

for ii=1:5
        savename = [outputDir,'SS',num2str(num1(ii)),'\start_time.mat'];
        savename1 = [outputDir,'SS',num2str(num1(ii)),'\lastepoch_time.mat'];
for sub=1:len1(ii)
    if sub<10
        bgFile = [objDir,num2str(num1(ii)),'\01-0',int2str(num1(ii)),'-000',int2str(sub),' Base_annotations.txt'];
    else
        bgFile = [objDir,num2str(num1(ii)),'\01-0',int2str(num1(ii)),'-00',int2str(sub),' Base_annotations.txt'];
    end
    
    lab=importdata(bgFile);
    %%%找出第一个标签的开始时间，是之与数据对应
    mark1=find(lab{2}==',',1);
    mark2=find(lab{end}==',',1);
    aa1=lab{2}(2:mark1-1);
    aa2=lab{end}(2:mark2-1);
    bb1=str2num(aa1);
    bb2=str2num(aa2);
    bb1=ceil(bb1*256);
    bb2=ceil(bb2*256);
    %%%
    first_point(sub)=bb1;
    last_point(sub)=bb2;
end
save(savename,'first_point');
clear first_point
save(savename1,'last_point');
clear last_point
end
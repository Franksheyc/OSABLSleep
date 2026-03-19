warning off
objDir='\\192.168.31.100\Data\13_公开数据集\公开数据集\nsrr\abc\polysomnography\annotations-events-profusion\month18';
outputDir='D:\database\data\';
n=dir(objDir);
tic
for i=1:length(n)-2
    na=n(i+2).name;
%     path=[objDir,'\',na0,'\polysomnography\annotations-events-profusion'];
%     n1=dir(path);
%     for ii=1:length(n1)-2
%         na=[n1(ii+2).name];
        filename=[objDir,'\',na];
        
        s=strfind(na,'.');
        if ~isempty(s)
            nb=na(1:s(1)-1);
        else
            nb=na;
        end
        savename0=[outputDir,'\abc\label'];
        mkdir(savename0);
        savename=[savename0,'\',nb,'mat'];%%%na名字需改
% % %            savename1=[outputDir1,num2str(i),'\',na(1:12),'ann.mat'];

        xmlDoc=xmlread(filename);
        label = getlabel_xml_1(xmlDoc);
% % %         label=zeros(sum(lab(:,2)),1);
% % %         a=1;b=0;
% % %         for ij=1:length(lab(:,2))
% % %             b=b+lab(ij,2); 
% % %             label(a:b)=lab(ij,1);
% % %             a=a+lab(ij,2);
% % %         end
        save(savename,'label');
% % %         save(savename1,'Annotations');
        clear label
% % %         clear Annotations
% % %         clear lab
%     end
    
end
toc
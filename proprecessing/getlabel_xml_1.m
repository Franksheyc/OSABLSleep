function label = getlabel_xml_1(xmlDoc)

IDArray = xmlDoc.getElementsByTagName('SleepStages');    % 将所有ImagePath节点放入数组IDArray
c=0;
 for i = 1 : IDArray.getLength   
    thisItem = IDArray.item(i-1);     
    childNode = thisItem.getFirstChild;
    childNodedata = char(childNode.getData);
% %   while ~isempty(childNode)  % 遍历PerHuman的所有子节点，也就是遍历 标注程序保存下来的各个数据点 节点
% %          ii=ii+1;
% %       if ii>9
% %           break
% %       elseif  childNode.getNodeType == childNode.ELEMENT_NODE    % 检查当前节点没有子节点，  childNode.ELEMENT_NODE 定义为没有子节点。
% %           childNodeNm = char(childNode.getTagName);        % 当前节点的名字
% %           childNodedata = char(childNode.getFirstChild.getData);    % 当前节点的内容
% %           annotations{ii}=childNodedata;
% %           childNode = childNode.getNextSibling;
% %       else
% %           childNode = childNode.getNextSibling;
% %       end  % End IF   
% % 
% %   end  % End WHILE
% %  a1=char(annotations(2));
% %  a2=char(annotations(4));
% %  a3=char(annotations(6));
% %  a4=char(annotations(8));
% %  if strcmp(childNodedata,'Stages|Stages')==1
% %     c=c+1;
% %     Annotations{c}={a2,a3,a4};
    switch childNodedata
        case '0'
            aa2=0;
        case '1'
            aa2=1;
        case '2'
            aa2=2;
        case '3'
            aa2=3;
        case '4'
            aa2=3;
        case '5'
            aa2=4;
        otherwise
            aa2=5;
    end
    label(i)=aa2;
% %     aa4=str2num(a4)/30;
% %     lab(c,:)=[aa2 aa4];
% %  end
 end

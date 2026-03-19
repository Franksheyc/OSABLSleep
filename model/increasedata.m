function [label,h,len,s]=increasedata(label,i)
if i==1
    times=0.03;
elseif i==3
    times=0.1;
else
    times=0.15;
end
r=length(find(label==i))/length(label);
if r~=0
    if r<times
        [label,h,s]=addlabels(label,i,times);
    else
        h=find(label==i);
        s=zeros(1,length(h));
    end
else
    h=[];
    s=[];
end
len=length(label);

end

% function [label,h,s]=addlabels(label,i,times)
% h=find(label==i);
% s=floor(times*length(label)/length(h))-1;
% if s~=0
% [label]=fixdata(label,h,s);
% end
% end

function [label,h,ss]=addlabels(label,i,times)

h=find(label==i);
if ~isempty(h)
    s=times*length(label)/length(h);
    s1=s-floor(s);
    s=floor(s)-1;
    h1=floor(s1*length(h));
    m=randperm(length(h));
    m=m(1:h1);
    s1=zeros(1,length(h));
    s1(m)=1;
    ss=ones(1,length(h))*s+s1;
    % if s~=0
    [label]=fixdata(label,h,ss);

else
   ss=zeros(1,length(h)); 
end
% end
end
function [bbox] = find_maximum_rectangle_in_us(mask,step)
boundry = mask-imerode(mask,strel('disk',1));
boundry([1,end],:) = mask([1,end],:);
boundry(:,[1,end]) = mask(:,[1,end]);
max_area = 0;
bbox = [];
figure()
for i = 1:step:size(boundry,1)
    xs = find(mask(i,:)==1);
    if(numel(xs)==0 | max(xs(2:end)-xs(1:end-1))~=1)
        continue
    end
    xs = [xs(1),xs(end)];
    y1 = find(boundry(:,xs(1))==1);
    y1 = max(y1(y1~=xs(1)));
    y2 = find(boundry(:,xs(2))==1);
    y2 = max(y2(y2~=xs(1)));
    y = min(y1,y2);
    curr_area = (y-i)*(xs(2)-xs(1));
    if(curr_area >=max_area)
        bbox = [xs(1),i,xs(2)-xs(1),y-i];
        max_area = curr_area;
    end
    c = repmat(boundry,[1,1,3]);
    c(i:y,xs,1)=1;
    c([i,y],xs(1):xs(2),1)=1;
    c(bbox(2):bbox(2)+bbox(4),[bbox(1),bbox(1)+bbox(3)],2)=1;
    c([bbox(2),bbox(2)+bbox(4)],bbox(1):bbox(1)+bbox(3),2)=1;
    imshow(c)
    drawnow()
    %pause(1)
end
end


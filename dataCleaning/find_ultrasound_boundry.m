function [mask,bbox] = find_ultrasound_boundry(vid_in_raw)
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils/geometry']));
margin = 8; %jpeg block size
if(isstring(vid_in_raw) || ischar(vid_in_raw))
    vid_in = readVideoFromFile(vid_in_raw,false);
else
    vid_in = vid_in_raw;
end
vid_g = imfilter(vid_in,reshape([-1,1],[1,1,2]));
changes = sum(abs(vid_g),3);
change_edges = abs(conv2(changes,[1,0,-1;2,0,-2;1,0,-1],'same'));
[h,t,r] = hough(change_edges>8);
p = houghpeaks(h,2,'Threshold',0.25*max(h,[],'all'));
lines = houghlines(change_edges>2,t,r,p);
m1 =  (lines(1).point1(2) - lines(1).point2(2)) /(lines(1).point1(1) - lines(1).point2(1));
m2 =  (lines(2).point1(2) - lines(2).point2(2)) /(lines(2).point1(1) - lines(2).point2(1));
n1 = lines(1).point1(2)-m1*lines(1).point1(1);
n2 = lines(2).point1(2)-m2*lines(2).point1(1);
[x_o,y_o] = line_line_intesection(m1,n1,m2,n2);
y_v = 1:size(change_edges,1);
x_v = 1:size(change_edges,2);
[x_m,y_m] = meshgrid(x_v,y_v);
d = (y_m-y_o).^2+(x_m-x_o).^2;
d = sqrt(d);
pos_d = d(change_edges>2);
r_min = min(pos_d)+margin;
r_max = max(pos_d)-margin;
mask = zeros(size(change_edges));
mask(d>=r_min & d<=r_max) = 1;
if(m1<0)
    temp=m1;
    m1=m2;
    m2=temp;
    temp=n1;
    n1=n2;
    n2=temp;
end
mask(m1*x_m+n1-y_m>0)=0;
mask(m2*x_m+n2-y_m>0)=0;
mask = imerode(mask,strel('square',margin));
bbox = find_maximum_rectangle_in_us(mask,5);
end


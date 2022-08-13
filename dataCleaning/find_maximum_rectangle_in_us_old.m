function [bbox] = find_maximum_rectangle_in_us_old(min_r,max_r,m1,n1,m2,n2)
root = getenv('TemporalSegmentation');
addpath(genpath([root,'/utils/geometry']));
[xo,yo] = line_line_intesection(m1,n1,m2,n2);
[xu1,yu1] = line_circle_intersection(m1,n1,min_r,xo,yo);
[~,imax] = max(yu1);
xu1 = xu1(imax);
yu1 = yu1(imax);
[xu2,yu2] = line_circle_intersection(m2,n2,min_r,xo,yo);
[~,imax] = max(yu2);
xu2 = xu2(imax);
yu2 = yu2(imax);
yu = max((yu1+yu2)/2,yo+min_r);

[xd1,yd1] = line_circle_intersection(m1,n1,max_r,xo,yo);
[~,imax] = max(yd1);
xd1 = xd1(imax);
yd1 = yd1(imax);
[xd2,yd2] = line_circle_intersection(m2,n2,max_r,xo,yo);
[~,imax] = max(yd2);
xd2 = xd2(imax);
yd2 = yd2(imax);
yd = min((yd2+yd1)/2,yo+max_r);
bbox = [yu,yd];
end


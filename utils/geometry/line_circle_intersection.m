function [xi,yi] = line_circle_intersection(m,n,r,xo,yo)
a = 1 + m^2;
b = 2*(m*(n - yo)-xo);
c = xo^2 + (n-yo)^2 - r^2;
xi(1) = (-b + sqrt(b^2 - 4*a*c)) / (2*a);
xi(2) = (-b - sqrt(b^2 - 4*a*c)) / (2*a);
yi = m*xi+n;
end


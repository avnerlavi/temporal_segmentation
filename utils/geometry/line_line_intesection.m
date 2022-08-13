function [xi,yi] = line_line_intesection(m1,n1,m2,n2)
xi = (n2-n1)/(m1-m2);
yi = m2*xi+n2;
end


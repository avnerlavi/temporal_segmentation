
function [imgout] = spline_interp2(img)

[m, n, ch]=size(img);
M = 2*m;
N = 2*n;
imgout = zeros(M,N,ch);
img1=zeros(M,N);

img1(1:2:M,1:2:N)=img;

%%
m = M;
n = N;
%0??
x=1:2:n;
y=img1(1:2:m,1:2:n);
%pp=csapi(x,y);
%pp=csape(x,y,'variational');
pp=pchip(x,y);
img1(1:2:m,1:n-1)=fnval(pp,1:n-1);
x1=1:2:m;
y1=img1(1:2:m,1:n-1);
y1=y1';
%pp=csapi(x1,y1);
%pp=csape(x1,y1,'variational');
pp=pchip(x1,y1);
img1(1:m-1,1:n-1)=(fnval(pp,1:m-1))';
img1(m,:)=img1(m-1,:);
img1(:,n)=img1(:,n-1);

%%
imgout= img1;

end


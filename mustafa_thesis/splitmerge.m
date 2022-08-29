isSeprateWin=1;

if(isSeprateWin==1)
    figure;imshow(Im);
end
%f=rgb2gray(Im);
f=uint8(Im);
[r c w]=size(f);
q=2^nextpow2(max(size(f)));
[m n]=size(f);
f=padarray(f,[q-m,q-n],'post');
mindim=12;

% s=qtdecomp(f,@split,mindim,@predicate);
s= qtdecomp(I,0.2);
lmax=full(max(s(:)));
g=zeros(size(f));
marker=zeros(size(f));
for k=1:lmax
    [vals,r,c]=qtgetblk(f,s,k);
    if ~isempty(vals)
        for i=1:length(r)
            xlow=r(i);ylow=c(i);
            xhigh=xlow+k-1;
            yhigh=ylow+k-1;
            region=f(xlow:xhigh,ylow:yhigh);
            flag=feval(@predicate,region);
            if flag
                g(xlow:xhigh,ylow:yhigh)=1;
                marker(xlow,ylow)=1;
            end
        end
    end
end

g=bwlabel(imreconstruct(marker,g));
g=g(1:m,1:n);
f=f(1:m,1:n);
h=medfilt2(g,[3 3]);

BWoutline=bwperim(h);
segout=f;
segout(BWoutline)=255;

if(isSeprateWin==1)
    figure;imshow(g,[])
    figure;imshow(h,[])
    figure;imshow(f,[])
    figure;imshow(segout,[])
end

function v=split(b,mindim,fun)
k=size(b,3);
v(1:k)=0;
for i=1:k
    quadrgn=b(:,:,i);
    if size(quadrgn,1)<=mindim
        v(i)=0;
        continue
    end
    flag=feval(fun,quadrgn);
    if flag
        v(i)=1;
    end
end
end

function flag=predicate(region)
sd=std2(region);
m=mean2(region);
flag=(sd>5)&&(m>0)&&(m<200);
end

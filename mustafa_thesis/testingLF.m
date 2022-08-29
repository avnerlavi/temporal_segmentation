close all
for i=1:24
    Path=['C:\Users\97254\Documents\MATLAB\thesis\dataset\train_images\img',num2str(i)];
    Format='png';
    ImC=imread([Path,'.',Format]);
    out=LF3(ImC);
    
end
%%
theta = [0:5:360];
KK=length(theta);
for i=1:KK
    tat=pi()*(i-1)/(KK-1);


    x=1:25;
    y=1:25;
    x0=13;
    y0=13;
    sig=8;
    lmd=12;

    exp1=0;
    L = zeros(size(y,2),size(x,2));
    Lnorm = zeros(size(y,2),size(x,2));
    %         
    for x1=1:size(x,2)
     for y1=1:size(y,2)
         exp1=exp(-((x(x1)-x0)^2/sig^2+(y(y1)-y0).^2/(sig)^2));
         L(y1,x1)=cos(2*pi/lmd*((x(x1)-x0)*cos(tat)+(y(y1)-y0)*sin(tat))).*exp1;
         Lnorm(y1,x1)=cos(2*pi/lmd*((x(x1)-x0)*cos(tat)+(y(y1)-y0)*sin(tat)));
     end
    end
    % Lnorm=imresize(Lnorm,1/5);
    % L=imresize(L,1/5);

    Lnorm  =conv2(Lnorm,L,'same');
    CONVnorm = Lnorm(ceil(size(L,1)/2),ceil(size(L,1)/2));
    figure(1);imshow(Lnorm,[])
end
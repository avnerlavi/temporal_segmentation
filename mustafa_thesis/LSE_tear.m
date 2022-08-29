lam1=1;
lam2=1;
mu=0.5;
nu=0.5;
p=1;

h=1;
dt=100;

I0=out; % import image
I1=out; % change an image into grey-scale image
I=atan((im2double(I1)*255-250).*5).*1000; % want to capture pixels with grey-scale 250~255

s=size(I);

x=-(s(1)-1)/2:h:(s(1)-1)/2; 
y=-(s(2)-1)/2:h:(s(2)-1)/2;

Nx=length(x);
Ny=length(y);

[X,Y]=meshgrid(y,x);

%phi=(X.^2+Y.^2).^0.5-min(Nx,Ny)/4; % define an initial level set
phi=zeros(size(I1,1),size(I1,2));
phi(110:120,135:145)=-10;
%% chan-vese algorithm
t=0;
while(t<1000)  
   t=t+dt;   
    H=phi(:,:)>=0;
    c1=sum(sum(I.*H))/sum(sum(H));
    c2=sum(sum(I.*(1-H)))/sum(sum(1-H));
    
    phi=horzcat(phi(:,2),phi,phi(:,Ny-1));
    phi=vertcat(phi(2,:),phi,phi(Nx-1,:));
    
    C1=zeros(Nx, Ny);
    C2=zeros(Nx, Ny);
    C3=zeros(Nx, Ny);
    C4=zeros(Nx, Ny);
    
    C1=1./(((phi(3:Nx+2,2:Ny+1)-phi(2:Nx+1,2:Ny+1)).^2+((phi(2:Nx+1,3:Ny+2)-phi(2:Nx+1,1:Ny)).^2)./4).^0.5+0.001);
    C2=1./(((phi(2:Nx+1,2:Ny+1)-phi(1:Nx,2:Ny+1)).^2+((phi(1:Nx,3:Ny+2)-phi(1:Nx,1:Ny)).^2)./4).^0.5+0.001);
    C3=1./((((phi(3:Nx+2,2:Ny+1)-phi(1:Nx,2:Ny+1)).^2)./4+(phi(2:Nx+1,3:Ny+2)-phi(2:Nx+1,2:Ny+1)).^2).^0.5+0.001);
    C4=1./((((phi(3:Nx+2,1:Ny)-phi(1:Nx,1:Ny)).^2)./4+(phi(2:Nx+1,2:Ny+1)-phi(2:Nx+1,1:Ny)).^2).^0.5+0.001);
    
    delta=zeros(Nx, Ny);
    delta=(h/pi)./(h^2+phi(2:Nx+1,2:Ny+1).^2);
   
    gradphi=zeros(Nx, Ny);
    gradphi=((phi(3:Nx+2,2:Ny+1)-phi(1:Nx,2:Ny+1)).^2+(phi(2:Nx+1,3:Ny+2)-phi(2:Nx+1,1:Ny)).^2).^0.5/(2*h);
    L= sum(sum(delta.*gradphi));
   
    F1=zeros(Nx, Ny);
    F2=zeros(Nx, Ny);
    F3=zeros(Nx, Ny);
    F4=zeros(Nx, Ny);
    F=zeros(Nx, Ny);
    P=zeros(Nx, Ny);
    
    F1=(dt*mu*p*L^(p-1)*delta.*C1)./(h+dt*mu*p*L^(p-1)*delta.*(C1+C2+C3+C4));
    F2=(dt*mu*p*L^(p-1)*delta.*C2)./(h+dt*mu*p*L^(p-1)*delta.*(C1+C2+C3+C4));
    F3=(dt*mu*p*L^(p-1)*delta.*C3)./(h+dt*mu*p*L^(p-1)*delta.*(C1+C2+C3+C4));
    F4=(dt*mu*p*L^(p-1)*delta.*C4)./(h+dt*mu*p*L^(p-1)*delta.*(C1+C2+C3+C4));
    F=h./(h+dt*mu*p*L^(p-1)*delta.*(C1+C2+C3+C4));
    P=phi(2:Nx+1,2:Ny+1)-dt*delta.*(nu+lam1*(I-c1).^2-lam2*(I-c2).^2);
    
    phi=F1.*phi(3:Nx+2,2:Ny+1)+F2.*phi(1:Nx,2:Ny+1)+F3.*phi(2:Nx+1,3:Ny+2)+F4.*phi(2:Nx+1,1:Ny)+F.*P; % ??? ?????? ???.
   
    R1=I>0.5;
    R2=phi<0;
    R1only=R1-R2;
    R2only=R2-R1;
    E1=size(R1only(R1only>0),1)/size(R1(R1>0),1);
    E2=size(R2only(R2only>0),1)/size(R2(R2>0),1);
    
    image(y,x,I0);
    hold on;
    contour(X,Y,phi,[0,0],'r'); % draw a segmentation
    pause(0.01);
end
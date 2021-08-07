function [k_local,k_remote] = calculatRemoteLocalFilters(ro_local,ro_remote,size_local,size_remote)
if(mod(size_local,2)==0)
    size_local = size_local+1;
end
if(mod(size_remote,2)==0)
    size_remote = size_remote+1;
end
k_local = fspecial('gaussian',size_local,sqrt(2)*ro_local);
%k_local = fspecial('gaussian',size_local,ro_local);
k_remote = fspecial('gaussian',size_remote,sqrt(2)*ro_remote);
y_local = 1:size(k_local,1);
x_local = 1:size(k_local,2);
y_remote = 1:size(k_remote,1);
x_remote = 1:size(k_remote,2);
[Y_local,X_local] = meshgrid(y_local,x_local);
[Y_remote,X_remote] = meshgrid(y_remote,x_remote);
R_local = sqrt((X_local - ceil(size(k_local,2)/2)).^2 + (Y_local - ceil(size(k_local,1)/2)).^2);
R_remote = sqrt((X_remote- ceil(size(k_remote,2)/2)).^2 + (Y_remote- ceil(size(k_remote,1)/2)).^2);
k_local(R_local>size_local/2) = 0;
k_remote(R_remote<size_local/2) = 0;
k_remote(R_remote>size_remote/2) = 0;
%k_local = k_local./sum(k_local,'all');
%k_remote = k_remote./sum(k_remote,'all');
end


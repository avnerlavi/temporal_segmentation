function T=opthr(I)


%Image size
[rows,cols]=size(I);
%Initial consideration: each corner of the image has background pixels.
%This provides an initial threshold (T), calculated as the mean of the gray levels contained
%in the corners. The width and height of each corner is a tenth of the image's width 
%and height, respectively.
col_c=floor(cols/10);
rows_c=floor(rows/2);
corners=[I(1:rows_c,1:col_c); I(1:rows_c,(end-col_c+1):end);...
         I((end-rows_c+1):end,1:col_c);I((end-rows_c+1):end,(end-col_c+1):end)];
T=nanmean(nanmean(corners));
%***************************************************************
% ITERATIVE PROCESS
%***************************************************************
while 1
  %1. The mean of gray levels corresponding to objects in the image is calculated.
  %The actual threshold (T) is used to determine the boundary between objects and
  %background.
  mean_obj=nansum(nansum( (I>T).*I ))/length(find(I>T));
  %2. The same is done for the background pixels.
  mean_backgnd=nansum(nansum( (I<=T).*I ))/length(find(I<=T));
 
  %3. A new threshold is calculated as the mean of the last results:
  new_T=(mean_obj+mean_backgnd)/2;
  %4. A new iteration starts only if the threshold has changed.
  if(new_T==T)
     break;   
  else
     T=new_T;   
  end
   
end 

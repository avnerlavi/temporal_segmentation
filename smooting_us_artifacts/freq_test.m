vid_matrix = readVideoFromFile("F:\Matlab\docs\temporal_segmentation\resources\material_from_ynon_19_1_22\raw_data\heart_malformation\אברמויץ סקירה 2.mp4", false,[(10*60*30+18*30),(10*60*30+27*30)]);
vid_matrix = vid_matrix(240:240+369,328:328+547,:);
dt = vid_matrix(:,:,2:end) - vid_matrix(:,:,1:end-1);
global_dt = sum(abs(dt),[1,2]);
global_dt = squeeze(global_dt);
fgdt = fft(global_dt);
fgdt_lp = fgdt;
low_pass=85;
fgdt_lp(end/2+1-low_pass:end/2+1+low_pass)=0;
f = linspace(0,60,length(fgdt));
band = f(end/2+1-low_pass:end/2+1+low_pass);
peaks_idx = find(abs(fgdt(end/2+1-low_pass:end/2+1+low_pass))>50000);
filt = sin(pi*f/band(peaks_idx(1)))./(f/band(peaks_idx(1))*pi);
filt(1)=1;
t_filt = fftshift(real(ifft(filt)));
t_filt=t_filt(end/2-8:end/2+8);
t_filt=t_filt(3:end);
t_filt = reshape(t_filt,[1,1,length(t_filt)]);
t_filt=t_filt/sum(t_filt);
vid_in = PadVideoReplicate(vid_matrix,2*length(t_filt));
smoothed = convn(vid_in,t_filt,'same');
smoothed = stripVideo(smoothed,2*length(t_filt));
implay(smoothed)
%%
local_dt =  sum(abs(dt(166-2:166+2,155-2:155+2,:)),[1,2]);
fldt = squeeze(fft(local_dt));
figure()
plot(abs(fldt))
%%
stable_indecies = find(abs(global_dt)>150);
dropped = vid_matrix(:,:,stable_indecies);
implay(dropped)
%%
h(1,1,1)=1;
h(1,1,2)=1;
dt_zeros = abs(dt)==0;
dt_zeros(:,:,end+1)=false;
dt_zeros=imdilate(dt_zeros,strel(h));
dt_ = vid_matrix;
% dt_(:,:,2:end) = dt; 
combined = vid_matrix;
% combined(abs(dt_)<=0.1) = smoothed(abs(dt_)<=0.1);
combined(dt_zeros) = smoothed(dt_zeros);
implay(combined)
%%
smoothed(smoothed<0)=0;
writeVideoToFile(smoothed, ...
    'smoothed', ['test\']);
writeVideoToFile(dropped, ...
    'dropped', ['test\']);
combined(combined<0)=0;
writeVideoToFile(combined, ...
    'combined_2', ['test\']);
writeVideoToFile(vid_matrix, ...
    'orig', ['test\']);
function [vid_out] = zero_grad_smooting(vid_in,n_frames,grad_threshold)
dt = vid_in(:,:,2:end) - vid_in(:,:,1:end-1);
dt(:,:,end+1) = 1;
line_filt = strel(ones(1,1,n_frames-1));
dt_eroded = imerode(abs(dt)<=grad_threshold,line_filt);
half_n = ceil((n_frames-1)/2)-1;
dt_eroded(:,:,end-half_n:end) = 0;
dt_eroded = circshift(dt_eroded,-half_n,3);
tri_filt = [1:n_frames,n_frames-1:-1:1];
tri_filt = tri_filt/max(tri_filt);
tri_filt = reshape(tri_filt,[1,1,length(tri_filt)]);
vid_out = vid_in;
vid_out(dt_eroded) = 0;
vid_out = PadVideoReplicate(vid_out,length(tri_filt));
vid_out = convn(vid_out,tri_filt,'same');
vid_out = stripVideo(vid_out,length(tri_filt));
vid_out(~dt_eroded) = vid_in(~dt_eroded);
end


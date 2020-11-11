function [totalVid] = compareVids(vid1raw,vid2raw,verbose)
if(isstring(vid1raw))
    vid1 = read_movie(vid1raw, false);
else
    vid1 = vid1raw;
end
if(isstring(vid2raw))
    vid2 = read_movie(vid2raw, false);
else
    vid2 = vid2raw;
end

vidSize = [max(size(vid2,1),size(vid1,1)),size(vid1,2)+size(vid2,2)+10,max(size(vid2,3),size(vid1,3))];
totalVid = 0.83*ones(vidSize);
totalVid(1:size(vid1,1),1:size(vid1,2),1:size(vid1,3)) = vid1;
totalVid(1:size(vid2,1),end-size(vid2,2)+1:end,1:size(vid2,3)) = vid2;
if(verbose)
    implay(totalVid);
end
end


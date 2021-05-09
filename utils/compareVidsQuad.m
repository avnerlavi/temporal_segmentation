function [total] = compareVidsQuad(vid1,vid2,vid3,vid4)
[~,t1] = compareVids(vid1,vid2,'verbose',false);
[~,t2] = compareVids(vid3,vid4,'verbose',false);
[~,t] = compareVids(permute(t1,[2,1,3]),permute(t2,[2,1,3]),'verbose',false);
total  = permute(t,[2,1,3]);
end


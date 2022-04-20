function [vidOut] = additiveCombination(vid_source, vid_additive, beta, gain)

additive_p = (max(vid_additive, 0))./(1+beta*vid_source);
additive_n = (max(-vid_additive, 0))./(1+beta*(1-vid_source));
vidOut = vid_source + gain * (additive_p - additive_n);

end

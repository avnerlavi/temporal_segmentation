function [vidDiff] = compareVids(vid1raw,vid2raw,varargin)
%% create default flags and parse optional parameters
parser = inputParser;
addRequired(parser, 'vid1raw');
addRequired(parser, 'vid2raw');
addOptional(parser, 'verbose', true, @islogical);
addOptional(parser, 'fps', 20, (@(x) isnumeric(x) && (x > 0)));
parse(parser, vid1raw, vid2raw, varargin{:});
%% compare videos
if(isstring(vid1raw))
    vid1 = readVideoFromFile(parser.Results.vid1raw, false);
else
    vid1 = parser.Results.vid1raw;
end
if(isstring(vid2raw))
    vid2 = readVideoFromFile(parser.Results.vid2raw, false);
else
    vid2 = parser.Results.vid2raw;
end

vidSize = [max(size(vid2,1),size(vid1,1)),size(vid1,2)+size(vid2,2)+10,max(size(vid2,3),size(vid1,3))];
totalVid = 0.83*ones(vidSize);
totalVid(1:size(vid1,1),1:size(vid1,2),1:size(vid1,3)) = vid1;
totalVid(1:size(vid2,1),end-size(vid2,2)+1:end,1:size(vid2,3)) = vid2;
if parser.Results.verbose
    implay(totalVid, parser.Results.fps);
end
vidDiff = zeros(size(vid1));
if size(vid1) == size(vid2)
    vidDiff = vid1 - vid2;
end
end


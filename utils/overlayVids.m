function [vidDiff, totalVid] = overlayVids(vid1raw,vid2raw,varargin)
%% create default flags and parse optional parameters
parser = inputParser;
addRequired(parser, 'vid1raw');
addRequired(parser, 'vid2raw');
addOptional(parser, 'verbose', true, @islogical);
addOptional(parser, 'fps', 20, (@(x) isnumeric(x) && (x > 0)));
addOptional(parser, 'method', 'Complementry', @(x) isstring(x)||ischar(x)) ;
parse(parser, vid1raw, vid2raw, varargin{:});

%% validity handling
if(isstring(vid1raw) || ischar(vid1raw))
    vid1 = readVideoFromFile(parser.Results.vid1raw, false);
else
    vid1 = parser.Results.vid1raw;
end
if(isstring(vid2raw) || ischar(vid2raw))
    vid2 = readVideoFromFile(parser.Results.vid2raw, false);
else
    vid2 = parser.Results.vid2raw;
end
if(~isequal(size(vid1),size(vid2))) % size check
    error('Videos must be of equal sizes to overlay')
end
if(length(size(vid1))~= 3) % assuming grayscale videos
 error('Videos must be 3 dimentional')
end

%% overlay
vidDiff = vid1-vid2;
if(strcmp(parser.Results.method,'Complementry'))
    totalVid(:,:,:,1) = vid1;
    totalVid(:,:,:,2) = vid2;
    totalVid(:,:,:,3) = vid2;
    totalVid = permute(totalVid,[1,2,4,3]);
elseif(strcmp(parser.Results.method,'Multiply'))
    totalVid = vid1.*vid2;
else
    error('unknown overlay method')
end

if parser.Results.verbose
    implay(totalVid, parser.Results.fps);
    maintainFitToWindow();
end

end
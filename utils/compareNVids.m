function [totalVid] = compareNVids(vid_list,varargin)
%% create default flags and parse optional parameters
parser = inputParser;
addRequired(parser, 'vid_list');
addOptional(parser, 'verbose', true, @islogical);
addOptional(parser, 'fps', 20, (@(x) isnumeric(x) && (x > 0)));
addOptional(parser, 'shape', [], (@(x) (length(x)==2 && isnumeric(x(1)) && (x(1) > 0) && (x(2) > 0))||isempty(x)));
parse(parser, vid_list, varargin{:});
%% compare videos
vid_size = [0,0,0];
for i = 1:length(vid_list)
    if(isstring(vid_list{i}) || ischar(vid_list{i}))
        vid_list{i} = readVideoFromFile(vid_list{i}, false);
    end
    vid_size = [max(vid_size(1),size(vid_list{i},1)),...
        max(vid_size(2),size(vid_list{i},2)),...
        max(vid_size(3),size(vid_list{i},3))];
end
if (numel(parser.Results.shape)==0)
    vid_shape(1) = floor(sqrt(length(vid_list)));
    vid_shape(2) = ceil(length(vid_list)/vid_shape(1));
else
    vid_shape = parser.Results.shape;
end
vid_size(1:2) = vid_size(1:2).*vid_shape + 10*vid_shape;
totalVid = 0.83*ones(vid_size);
y_i = 0;
x_i = 0;
for i  = 1:length(vid_list)
    y = floor(vid_size(1)*y_i/vid_shape(1))+1;
    x = floor(vid_size(2)*x_i/vid_shape(2))+1;
   totalVid(y:size(vid_list{i},1)+y-1,x:size(vid_list{i},2)+x-1,1:size(vid_list{i},3)) = vid_list{i};
   x_i = x_i+1;
   if(x_i >= vid_shape(2))
       x_i = 0;
       y_i = y_i +1;
   end
end
if parser.Results.verbose
    implay(totalVid, parser.Results.fps);
    maintainFitToWindow();
end

end


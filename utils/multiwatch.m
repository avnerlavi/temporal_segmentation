function multiwatch(vidIn, varargin)
%% create default flags and parse optional parameters
parser = inputParser;
addRequired( parser, 'vidIn');
addParameter(parser, 'displayMinMax'  , true  , @islogical);
addParameter(parser, 'displayNormed'  , true  , @islogical);
addParameter(parser, 'fps'            , 20    , (@(x) isnumeric(x) && (x > 0)));
addParameter(parser, 'displayPermuted', true  , @islogical);
parse(parser, vidIn, varargin{:});
%% list maximum and minimum values
if parser.Results.displayMinMax
    max_val = max(vidIn, [], 'all');
    min_val = min(vidIn, [], 'all');
    fprintf('minimum: %d\n', min_val);
    fprintf('maximum: %d\n', max_val);
end
%% normalize video
vidNormed = abs(vidIn);
vidNormed = vidNormed / max(vidNormed, [], 'all');
if parser.Results.displayNormed
    implay(vidNormed, parser.Results.fps);
    maintainFitToWindow();
end
%% calculate and display x-t/y-t permutations
if parser.Results.displayPermuted
    permuted_xt = permute(vidNormed, [1,3,2]);
    permuted_yt = permute(vidNormed, [2,3,1]);
    compareVids(permuted_xt, permuted_yt, true, parser.Results.fps);
end
end
function [vidPadded] = PadVideoReplicate(vidIn,padding)
vidPadded = vidIn;
for i=1:3
    s = size(vidPadded);
    temp = zeros([s(1) + 2*padding, s(2), s(3)]);
    temp(padding+1:end-padding, :, :) = vidPadded;
    temp(1:padding,:,:) = repmat(vidPadded(1,:,:), [padding, 1, 1]);
    temp(end-padding+1:end,:,:) = repmat(vidPadded(end,:,:), [padding, 1, 1]);
    %we tried make it more elegant - took more time
    %    temp = vertcat(repmat(vidPadded(1,:,:), [padding, 1, 1]),vidPadded,repmat(vidPadded(end,:,:), [padding, 1, 1]));
    vidPadded = permute(temp, [2, 3, 1]);
end
end


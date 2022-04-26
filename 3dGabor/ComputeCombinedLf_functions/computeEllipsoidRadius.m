function radius = computeEllipsoidRadius(theta, primaryAxis, secondaryAxis)
denum = primaryAxis.^2 .* sind(theta).^2 + secondaryAxis.^2 .* cosd(theta).^2;
denum = sqrt(denum);
radius = (primaryAxis .* secondaryAxis) ./ denum;
end


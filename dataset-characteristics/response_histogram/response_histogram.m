function [hist,edges] = response_histogram(vid_in,response,verbose)
edges = linspace(0,1,100);
vid_discretizied = discretize(vid_in,edges); 
hist = zeros(size(edges));
for i = 1:length(edges)
    hist(i) = mean(response(vid_discretizied == i));
end
if(verbose)
    figure()
    bar(edges,hist)
end
end


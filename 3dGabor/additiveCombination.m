function [vidOut] = additiveCombination(vid_source, vid_additive, beta, gain)

beta_x_const = (beta - 1) ./ (2*beta);
beta_y_const =  4*beta ./ (1 + beta).^2;
additive_p = (max(vid_additive, 0)) ./ (1 + beta*vid_source);
additive_p(vid_source >= beta_x_const) = beta_y_const .* max(vid_additive(vid_source >= beta_x_const), 0) .*...
    (1 - vid_source(vid_source >= beta_x_const));
additive_n = (max( -vid_additive, 0))./(1 + beta*(1 - vid_source));
additive_n((1 - vid_source) >= beta_x_const) = beta_y_const .* max(-vid_additive((1 - vid_source) >= beta_x_const), 0) .*...
    (vid_source((1 - vid_source) >= beta_x_const));

vidOut = vid_source + gain * (additive_p - additive_n);

end


function [vidOut] = additiveCombination(vid_source, vid_additive, beta, gamma, gain)

tanget_x_coord = (beta - 1) ./ (2*beta);
tangent_slope =  4*beta ./ (1 + beta).^2;

vid_additive_gamma_corrected = sign(vid_additive).*abs(vid_additive).^gamma;
vid_additive_p = max(vid_additive_gamma_corrected, 0);
vid_additive_n = max(-vid_additive_gamma_corrected, 0);
vid_source_inverted = 1-vid_source;

additive_p_harmonic = vid_additive_p ./ (1 + beta * vid_source);
additive_p_linear = tangent_slope .* vid_additive_p .* (1 - vid_source);
additive_p = additive_p_harmonic;
additive_p(vid_source >= tanget_x_coord) = additive_p_linear(vid_source >= tanget_x_coord);

additive_n_harmonic = vid_additive_n ./ (1 + beta * vid_source_inverted);
additive_n_linear = tangent_slope .* vid_additive_n .*(1 - vid_source_inverted);
additive_n = additive_n_harmonic;
additive_n(vid_source_inverted >= tanget_x_coord) = additive_n_linear(vid_source_inverted >= tanget_x_coord);

vidOut = vid_source + gain * (additive_p - additive_n);

end


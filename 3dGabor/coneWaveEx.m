

P = [1,0,0;0,1,0;0,0,0];
d = P*R*r';
d2 = sum(d.^2,1);
d2 = d2/max(abs(d2(:)));
d2 = reshape(d2,shape);
implay(cos(20*pi*d2))
implay(d2)
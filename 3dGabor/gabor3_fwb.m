function varargout = gabor3_fwb(aspect, angles, wavelength, phase, sigma, shape)
% Returns 3D gabor filter.
% gb=GABOR_FWB(aspect,theta,bw,psi,sigma,sz)
%
% [aspecta, aspectb]
%        = 2 element array giving aspect ratios for 2 minor axis
%           (eg: [0.5, 1], for major < minoraxis1, major = minoraxi2)
% [theta,phi]
%        = yaw and pitch of major axis (0-2*pi)
%           roll isn't implemented, sorry.
% bw     = spatial bandwidth in pixels (decreasing fine detail,), (eg: >=1)
%               scales the frequency of the cosine modulation
% psi,   = phase shift, [optional, default: 0]
% sigma  = scales the falloff of the gaussian, (must be >=2) [default: = bw]
%              + can set to 'auto' to maintain default functionality
% [x y z] = size of gabor kernel created  [optional, size set automatically
%           to 3 standard deviations of gaussian kernel]
% Frederick Bryan adapted from gabor_fn.m
% July 2013
% Vanderbilt Univ
% To Do
% implement roll:
% This isn't hard as far as the meshgrid goes. All that needs to be done for that is to
% uncomment the appropriate lines. I just didn't want to figure out the math
% for the auto-sizing option. (if nargin < 6)
%
% handle mandatory args
if numel(aspect) ~= 2
    error('1st argument (aspect) must be 2 element array');
end
% if numel(theta) ~=2
%     error('2nd argument ([theta,phi]) must be 2 element array');
% end
% yawAngle = angles(1);
% pitchAngle = angles(2);
% rollAngle = angles(3);
alpha = angles(1);
beta = angles(2);
% handle optional inputs
if nargin<4
    phase = [0 0];
end
if nargin<5
    sigma = 'auto';
end
% allow 'auto' sizing of guassian kernel
if strcmp(sigma,'auto')
    sigma = wavelength;
end
% handle incorrectly given optional args
if length(shape)<2 % allow just one number to be given for size
    shape(2) = shape(1);
    shape(3) = shape(1);
end
% keyboard;
sx = shape(1);
sy = shape(2);
sz = shape(3);
% figured out size above, now make matrix of points
[x, y, z]=meshgrid(-sx:sx, -sy:sy, -sz:sz);
% rotate reference frame to point in theta direction
% http://en.wikipedia.org/wiki/Rotation_matrix
xRotated = x * cosd(alpha) - y * sind(alpha);
yRotated = x * sind(alpha) + y * cosd(alpha);

yRotated = yRotated * cosd(beta) - z * sind(beta);
zRotated = yRotated * sind(beta) + z * cosd(beta);

% % roll
% xRotated = x;
% yRotated = y*cosd(rollAngle) - z*sind(rollAngle);
% zRotated = y*sind(rollAngle) + z*cosd(rollAngle);
% % pitch
% xRotated = xRotated*sind(pitchAngle) + zRotated*cosd(pitchAngle);
% yRotated = yRotated;
% zRotated = -xRotated*cosd(pitchAngle) + zRotated*sind(pitchAngle);
% % yaw
% xRotated = xRotated*cosd(yawAngle) - yRotated*sind(yawAngle);
% yRotated = xRotated*sind(yawAngle) + yRotated*cosd(yawAngle);
% zRotated = zRotated;
% create gaussian pointing in theta direction with size determined by
%   aspect ratio
sigmajor = sigma;
sigminor1 = sigma/aspect(1);
sigminor2 = sigma/aspect(2);
h1 = exp(-(xRotated.^2/sigmajor^2 + yRotated.^2/sigminor1^2 + zRotated.^2/sigminor2^2)/2) ...
    /(2*pi^1.5 * sigmajor*sigminor1*sigminor2);
% multiply by cosine with appropriate bw
F=1/wavelength;  % Frequency
h2 = cos(2*pi*F*(xRotated)+phase);
g = h1.*h2;

% h2_2 = cos(2*pi*F*(sind(rollAngle)*cosd(yawAngle)*x + sind(rollAngle)*sind(yawAngle)*y + cosd(rollAngle)*z)+phase);
h2_2 = cos(2*pi*F*sqrt(xRotated.^2 + yRotated.^2)+phase);
g = h1.*h2_2;

if nargout>0
    varargout{1} = g;
end
end

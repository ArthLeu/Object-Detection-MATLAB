function [mag,ori] = mygradient(I)
%
% compute image gradient magnitude and orientation at each pixel
%
%

assert(ndims(I)==2,'input image should be grayscale');

% declare sobel filter for edge detection
hx = [-1, 0, 1; -2, 0, 2; -1, 0, 1;];
hy = transpose(hx);

% horizontal and vertical derivative
dx = imfilter(I, hx, 'replicate');
dy = imfilter(I, hy, 'replicate');

% magnitude and orientation (angle)
mag = sqrt(double(dx.^2) + double(dy.^2));
ori = (atan2(double(dy), double(dx)).*180)./pi; % clockwise but atan2 return ccw

assert(all(size(mag)==size(I)),'gradient magnitudes should be same size as input image');
assert(all(size(ori)==size(I)),'gradient orientations should be same size as input image');

% figure(1)
% imagesc(mag)
% colorbar
% colormap jet
% title('Magnitude')
% 
% figure(2)
% imagesc(ori)
% colorbar
% colormap hsv
% title('Orientation (degree)')


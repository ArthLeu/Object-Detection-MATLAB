%
% This is a simple test script to exercise the detection code.
%
% It assumes that the template is exactly 16x16 blocks = 128x128 pixels.  
% You will want to modify it so that the template size in blocks is a
% variable you can specify in order to run on your own test examples
% where you will likely want to use a different sized template
%

% load a training example image
Itrain = im2double(rgb2gray(imread('signtest/test2.jpg')));

%have the user click on some training examples.  
% If there is more than 1 example in the training image (e.g. faces), you could set nclicks higher here and average together

% custom click time, size, detecting number
nclick = 4;
negclick = 4;
size = 10;
ndet = 5;

figure(1); clf;
imshow(Itrain); title(['select ',num2str(nclick),' positive training example(s)']);
[x,y] = ginput(nclick); %get nclicks from the user

%compute 8x8 block in which the user clicked
blockx = round(x/8);
blocky = round(y/8); 

%visualize image patch that the user clicked on
% the patch shown will be the size of our template
% since the template will be 16x16 blocks and each
% block is 8 pixels, visualize a 128pixel square 
% around the click location.
errTtl = 'Detection Stopped';
errMsg = 'Error: Selection(s) too close to image boundary; Decrease block size or select nearer towards image center.';


for i = 1:nclick
    try
        patch = Itrain(8*blocky(i)+(-size*8+1:size*8),8*blockx(i)+(-size*8+1:size*8));
        figure(2); subplot(ceil(nclick/2),2,i); imshow(patch);
    catch
        errordlg(errMsg, errTtl);
        return;
    end
end

% compute the hog features
f = hog(Itrain);

% compute the average template for the user clicks
postemplate = zeros(16,16,9);
for i = 1:nclick
  postemplate = postemplate + f(blocky(i)+(-7:8),blockx(i)+(-7:8),:); 
end
postemplate = postemplate/nclick;


% TODO: also have the user click on some negative training
% examples.  (or alternately you can grab random locations
% from an image that doesn't contain any instances of the
% object you are trying to detect).
figure(3); clf;
imshow(Itrain); title(['select ',num2str(negclick),' negative training example']);
[x,y] = ginput(negclick); %get nclicks from the user

%compute 8x8 block in which the user clicked
blockx = round(x/8);
blocky = round(y/8); 

for i = 1:negclick
    try
        patch = Itrain(8*blocky(i)+(-size*8+1:size*8),8*blockx(i)+(-size*8+1:size*8));
        figure(4); subplot(ceil(negclick/2),2,i); imshow(patch);
    catch
        errordlg(errMsg, errTtl);
        return;
    end
end

% now compute the average template for the negative examples
negtemplate = zeros(16,16,9);
for i = 1:negclick
  negtemplate = negtemplate + f(blocky(i)+(-7:8),blockx(i)+(-7:8),:); 
end
negtemplate = negtemplate/negclick;


% our final classifier is the difference between the positive
% and negative averages
template = postemplate - negtemplate;

%
% load a test image
%
Itest= im2double(rgb2gray(imread('signtest/test4.jpg')));


% find top 8 detections in Itest
[x,y,score] = detect(Itest,template,ndet);
ndet = length(x);

%display top ndet detections
figure(7); clf; imshow(Itest);
for i = 1:ndet
  % draw a rectangle.  use color to encode confidence of detection
  %  top scoring are green, fading to red
  hold on; 
  h = rectangle('Position',[x(i)-size*8 y(i)-size*8 size*8*2 size*8*2],'EdgeColor',[(i/ndet) ((ndet-i)/ndet)  0],'LineWidth',3,'Curvature',[0.3 0.3]); 
  hold off;
end

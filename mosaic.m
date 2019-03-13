close all;
% visualize the matches
visualizeMatches

ima = imread('zelf1.jpg');
imb = imread('zelf2.jpg');

% convert images for vl_sift
Ia = single(rgb2gray(ima));
Ib = single(rgb2gray(imb));

% get the keypoints using vlfeats sift
[fa, da] = vl_sift(Ia) ;
[fb, db] = vl_sift(Ib) ;

% and get the matches using vlfeat
[matches, scores] = vl_ubcmatch(da, db);

% use RANSAC to find the best homography
% We want a 99 % change that we get a good sample, by looking at the
% matches and counting outliers we set the change of outlier to be
% 17 %
matrix = RANSAC(matches, fa, fb, 0.8, 0.99, .5);
[x y] = tformfwd(matrix,[1 size(ima,2)], [1 size(ima,1)])

figure

xdata = [min(1,x(1)) max(size(imb,2),x(2))]
ydata = [min(1,y(1)) max(size(imb,1),y(2))]
ima2 = imtransform(ima,matrix,'Xdata',xdata,'YData',ydata);
imb2 = imtransform(imb, maketform('affine', [1 0 0; 0 1 0; 0 0 1]), 'Xdata',xdata,'YData',ydata);
subplot(1,1,1);
imshow(max(ima2,imb2));
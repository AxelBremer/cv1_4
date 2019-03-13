close all
im1 = im2single(rgb2gray(imread('left.jpg')));
im2 = im2single(rgb2gray(imread('right.jpg')));
% N = 100;
% p = 10;
% 
% [matches, fa, da, fb, db] = keypoint_matching(im1, im2);
% 
% [weights, translation] = RANSAC2(matches, fa, fb, N, p);

%transformation = RANSAC(im1, im2);

transform = RANSAC(im2, im1, 0);
tform = affine2d([transform(1) transform(3) 0; transform(2) transform(4) 0; transform(5) transform(6) 1]);

% H = [ weights(1), weights(3), 0; weights(2) , weights(4), 0; translation(1) * -1, translation(2) * -1, 1 ];
% transf = affine2d(H);

im2t = imwarp(im2, tform, 'nearest', 'OutputView', imref2d([400, 600]));


imshow(im2t)
figure
[h1, w1] = size(im1);
[h2, w2] = size(im2t);

final_im = zeros([h2, w2]);
final_im(1:h1, 1:w1) = im1;
final_im = max(final_im, im2t);

imshow(final_im)
l = im2single(rgb2gray(imread('l.jpg')));
r = im2single(rgb2gray(imread('r.jpg')));
left = im2single(rgb2gray(imread('left.jpg')));
right = im2single(rgb2gray(imread('right.jpg')));
stitched_img = stitch(left, right);

figure
subplot(1,3,1);
imshow(left);
subplot(1,3,2);
imshow(right);
subplot(1,3,3);
imshow(stitched_img);
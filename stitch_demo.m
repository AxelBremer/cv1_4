left = im2single(rgb2gray(imread('left.jpg')));
right = im2single(rgb2gray(imread('right.jpg')));
stitched_img = stitch(left, right);

figure
subplot(1,2,1);
imshow(left);
subplot(1,2,2);
imshow(right);
figure
imshow(stitched_img);
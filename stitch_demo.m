left = imread('left.jpg');
right = imread('right.jpg');

stitched_img = stitch(left, right);

figure
subplot(1,3,1);
imshow(left);
subplot(1,3,2);
imshow(right);
subplot(1,3,3);
imshow(stitched_img);

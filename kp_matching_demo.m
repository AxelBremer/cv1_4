im1 = im2single(imread('boat1.pgm'));
im2 = im2single(imread('boat2.pgm'));

matches = keypoint_matching(im1, im2, 1);
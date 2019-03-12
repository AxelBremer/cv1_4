close all;

im1 = im2single(imread('boat1.pgm'));
im2 = im2single(imread('boat2.pgm'));
RANSAC(im1, im2);

RANSAC(im2, im1);
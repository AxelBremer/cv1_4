function stitched_img = stitch(left, right)
transform = RANSAC(right, left, 0);
tform = affine2d([transform(1) transform(3) 0; transform(2) transform(4) 0; transform(5) transform(6) 1]);

warped_img = imwarp(right, tform);
imshow(warped_img);
end
function stitched_img = stitch(left, right)
transform = RANSAC(right, left, 0);
tform = affine2d([transform(1) transform(3) 0; transform(2) transform(4) 0; transform(5) transform(6) 1]);
warped_img = imwarp(right, tform, 'nearest');

translated_img = imtranslate(warped_img, [transform(5), transform(6)], 'nearest', 'OutputView','full');

[x, y] = size(translated_img);

stitched_img = zeros([x, y]);
stitched_img(1:size(left, 1), 1:size(left, 2)) = left;
stitched_img = max(stitched_img, translated_img);
end
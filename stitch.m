function stitched_img = stitch(left, right)
transform = RANSAC(right, left, 0);
tform = affine2d([transform(1) transform(3) 0; transform(2) transform(4) 0; transform(5) transform(6) 1]);


[d1, d2] = get_stitch_size(transform, left, right);

warped_img = imwarp(right, tform, 'nearest', 'OutputView', imref2d([d1,d2]));

stitched_img = zeros(size(warped_img));
stitched_img(1:size(left, 1), 1:size(left, 2)) = left;
stitched_img = max(stitched_img, warped_img);
end

function [d1, d2] = get_stitch_size(transform, left, right)
    tform = maketform('affine', [transform(1) transform(3) 0; transform(2) transform(4) 0; transform(5) transform(6) 1]);
   
    [dim2 dim1] = tformfwd(tform,[1 size(right,2)], [1 size(right,1)]);

    d1 = floor(max(size(left,1),dim1(2)));
    d2 = floor(max(size(left,2),dim2(2)));
end
function stitched_img = stitch(left, right)
transform = RANSAC(right, left, 0);
tform = affine2d([transform(1) transform(3) 0; transform(2) transform(4) 0; transform(5) transform(6) 1]);
warped_img = imwarp(right, tform, 'nearest');

[d1, d2, v_offset, h_offset] = get_stitch_size(transform, left, right)
keyboard
translated_img = imtranslate(warped_img, [transform(5)+h_offset, transform(6)+v_offset], 'nearest', 'OutputView','full');
left = imtranslate(left, [h_offset, v_offset], 'nearest', 'OutputView','full');

imshow(translated_img);

stitched_img = zeros([d1, d2]);
stitched_img(1:size(left, 1), 1:size(left, 2)) = left;
stitched_img = max(stitched_img, translated_img);
end

function [d1, d2, v_offset, h_offset] = get_stitch_size(transform, left, right)
    m = [transform(1) transform(2); transform(3) transform(4)];
    t = [transform(5), transform(6)]';
    corners = zeros(2,4);
    corners(:,1) = (m * [1,1]') + t;
    corners(:,2) = (m * [1,size(right,2)]') + t;
    corners(:,3) = (m * [size(right,1),0]') + t;
    corners(:,4) = (m * [size(right,1),size(right,2)]') + t;
    vert1 = min(corners(1,:));
    vert2 = max(corners(1,:));
    hor1 = min(corners(2,:));
    hor2 = max(corners(2,:));
    d1 = floor(max(vert2,size(left,1))+1);
    d2 = max(hor2,size(left,2));
    v_offset = 0;
    h_offset = 0;
    if vert1 < 0
        v_offset = -vert1;
        d1 = d1 + v_offset;
    end
    if hor1 < 0
        h_offset = -hor1;
        d2 = d2 + h_offset;
    end
end
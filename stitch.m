function stitched_img = stitch(left, right)
transform = RANSAC(right, left, 0);
tform = affine2d([transform(1) transform(3) 0; transform(2) transform(4) 0; transform(5) transform(6) 1]);

[d1, d2, v_offset, h_offset] = get_stitch_size(transform, left, right);

warped_img = imwarp(right, tform, 'nearest', 'OutputView', imref2d([500,500]));
%keyboard;
%translated_img = imtranslate(warped_img, [transform(5)+h_offset, transform(6)+v_offset], 'nearest', 'OutputView','full');
%left = imtranslate(left, [h_offset, v_offset], 'nearest', 'OutputView','full');

%stitched_img = zeros([d1, d2]);
stitched_img = zeros(size(warped_img));
stitched_img(1:size(left, 1), 1:size(left, 2)) = left;
stitched_img = max(stitched_img, warped_img);
end

function [d1, d2, v_offset, h_offset] = get_stitch_size(transform, left, right)
    m = [transform(1) transform(2); transform(3) transform(4)];
    t = [transform(5), transform(6)]';
    keyboard
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

function a = imwarp_same(a, varargin)
%IMWARP_SAME transforms an image into the original coordinates
%   B = IMWARP_SAME(A, TFORM) transforms image IM using the geometric
%   transformation object TFORM, by calling IMWARP. Unlike the default for
%   IMWARP there is no change of coordinates - the origin of the both the
%   original and the new image is at row 0, column 0.
%
%   B = IMWARP_SAME(A, RA, TFORM) transforms the spatially referenced image
%   specified by A and its associated spatial referencing object RA. The
%   output is spatially referenced by RA also.
% 
%   B = IMWARP_SAME(..., INTERP, NAME, VALUE, ...) allows additional
%   arguments as for IMWARP. INTERP is an optional string specifying the
%   form of interpolation to use. NAME, if given, must be the string
%   'FillValues' and VALUE must be the value to use for output pixels
%   outside the image boundaries. ('OutputView' may not be used as it is
%   implicit for this function.)
%
%   See also: IMWARP

if isa(varargin{1}, 'imref2d')
    ra = varargin{1};
elseif varargin{1}.Dimensionality == 2
    ra = imref2d(size(a));
else
    ra = imref3d(size(a));
end

a = imwarp(a, varargin{:}, 'OutputView', ra);

end
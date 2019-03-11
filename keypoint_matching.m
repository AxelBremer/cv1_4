function keypoint_matches = keypoint_matching(im1, im2, print)
    set_size = 10
    [f1,d1] = vl_sift(im1);
    [f2,d2] = vl_sift(im2);
    [matches, scores] = vl_ubcmatch(d1, d2);
    
    matches1 = f1(1:2,matches(1,:));
    matches2 = f2(1:2,matches(2,:));
    keypoint_matches = cat(1,matches1,matches2);
    
    if print == 1
        perm = randperm(size(matches,2));
        sel = perm(1:set_size);
        m_sel = matches(:,sel);
        s_sel = scores(:,sel);
        
        im_width = size(im1,2);
        big_im = cat(2,im1,im2);
        imshow(big_im);
        hold on;

        for i = 1:set_size
            match = m_sel(:,i);
            f_1 = f1(:,match(1));
            f_2 = f2(:,match(2));
            f_2(1,:) = f_2(1,:) + im_width;
            h1 = vl_plotframe(f_1);
            h1 = vl_plotframe(f_2);
            plot([f_1(1,:) f_2(1,:)],[f_1(2,:) f_2(2,:)]);
        end
    end
end
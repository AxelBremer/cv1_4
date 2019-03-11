function keypoints = keypoint_matching(im1, im2)
    [f1,d1] = vl_sift(im1);
    imshow(im1);
    hold on;
    perm = randperm(size(f1,2));
    sel = perm(1:50) ;
    h1 = vl_plotframe(f1(:,sel)) ;
    h2 = vl_plotframe(f1(:,sel)) ;
    set(h1,'color','k','linewidth',3) ;
    set(h2,'color','y','linewidth',2) ;
end
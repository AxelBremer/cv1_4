function transform = RANSAC(image1, image2, print)
    matches = keypoint_matching(image1, image2, 0);

    gold_t = matches(3:4,:);
    P = 3;
    N = 19;
    if N > size(matches, 1)
        N = size(matches,1);
    end
    
    best_tform = [0 0 0 0 0 0]';
    best_score = 0;

    for run=1:N
        score = 0;
        perm = randperm(size(matches,2));
        sel = perm(1:P);
        m_sel = matches(:,sel);
        transform = m_sel(3:4,:);
        b = reshape(transform,[P*2,1]);
        A = get_A(m_sel(1:2,:));
        
        tform = pinv(A)*b;
        
        m = [tform(1) tform(2); tform(3) tform(4)];
        t = [tform(5), tform(6)]';
        
        for i = 1:size(gold_t,2)
            xy = [matches(1,i) matches(2,i)]';
            uv = (m * xy) + t;
            d = norm(gold_t(:,i) - uv);
            if d < 10
                score = score + 1;
            end
        end
        
        if score > best_score
            best_score = score;
            best_tform = tform;
        end
    end
    
    transform = best_tform;
    
    if print == 1
        figure(1);
        plot_transform(image1, image2, matches, best_tform);
        h = figure(2);
        tform = affine2d([transform(1) transform(3) 0; transform(2) transform(4) 0; transform(5) transform(6) 1]);
        subplot(131)
        imshow(image2);
        title('original transformed image');
        subplot(132)
        imshow(imwarp(image1, tform));
        title('imwarp transformed image');
        subplot(133)
        imshow(rotateim(image1, tform));
        title('NN interpolation');
        waitfor(h)
    end
end

function A = get_A(points)
    A = [];
    for i = 1:size(points,2)
        x = points(1,i);
        y = points(2,i);
        A(end+1:end+2,:) = [x y 0 0 1 0 ; 0 0 x y 0 1];
    end
end

function plot_transform(image1, image2, matches, tform)
    set_size = 20;
    im_width = size(image1,2);
    big_im = cat(2,image1,image2);
    imshow(big_im);
    hold on;
    
    m = [tform(1) tform(2); tform(3) tform(4)];
    t = [tform(5), tform(6)]';
    uv = [];

    for i = 1:size(matches,2)
        xy = [matches(1,i) matches(2,i)]';
        uv(:,end+1) = (m * xy) + t;
    end
    u = uv(1,:);
    v = uv(2,:);
    u_moved = u + im_width;
    
    perm = randperm(size(matches,2));
    sel = perm(1:set_size);
    m_sel = matches(:,sel);
    u_sel = u_moved(sel);
    v_sel = v(sel);
    
    plot(m_sel(1,:), m_sel(2,:), 'o', 'color' ,'b');
    plot(u_sel,v_sel,'o', 'color','r');
    for i = 1:set_size
        plot([m_sel(1,i) u_sel(i)], [m_sel(2,i) v_sel(i)]);
    end
end

function im = rotateim(image, tform)
    [x_len, y_len] = size(image);
    
    % Calculate the size of the new image
    [c1_x, c1_y] = transformPointsForward(tform, 1, 1);
    [opp_c1_x, opp_c1_y] = transformPointsForward(tform, x_len, y_len);
    dist1 = sqrt( ( c1_x - opp_c1_x )^2 + ( c1_y - opp_c1_y )^2 );
    
    [c2_x, c2_y] = transformPointsForward(tform, 1, y_len);
    [opp_c2_x, opp_c2_y] = transformPointsForward(tform, x_len, 1);
    dist2 = sqrt( ( c2_x - opp_c2_x )^2 + ( c2_y - opp_c2_y )^2 );
    
    if dist1 > dist2
        im = zeros(ceil(dist1), ceil(dist1));
        imsize = dist1;
    else
        im = zeros(ceil(dist2), ceil(dist2));
        imsize = dist2;
    end
    
    % Fill the new image in pixel by pixel
%     for i = 1:imsize
%         for j = 1:imsize
%             [old_x, old_y] = transformPointsInverse(tform, i, j);
%             if old_x > 0.5 && old_y > 0.5 && old_x < x_len && old_y < y_len
%                 % Nearest neighbor
%                 nn_x = floor(old_x + 0.5);
%                 nn_y = floor(old_y + 0.5);
%                 pixel_val = image(nn_x, nn_y);
%                 im(i, j) = pixel_val;
%             end
% 
% %             [new_x, new_y] = transformPointsForward(tform, i, j);
% %             new_x = floor(new_x + 0.5)
% %             new_y = floor(new_y + 0.5)
% %             im(new_x, new_y) = image(i, j);
%         end
%     end
end
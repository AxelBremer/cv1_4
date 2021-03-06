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
%         imshow(imwarp(image1, tform, 'nearest'));
        title('imwarp transformed image');
        subplot(133)
        imshow(rotateim(image1, transform));
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

function im = rotateim(image, transform)
    
    [x_len, y_len] = size(image);
    x_half = (x_len / 2);
    y_half = (y_len / 2);
    
    orig_affine = [transform(1) transform(3) 0;...
                   transform(2) transform(4) 0;...
                   transform(5) transform(6) 1];

    affine = inv(orig_affine);
    
    % calculate the padding that is necessary for the transformation
    
    a = orig_affine * [1 - x_half; 1 - y_half; 1];
    b = orig_affine * [x_len - x_half; y_len - y_half; 1];
    c = orig_affine * [1 - x_half; y_len - y_half; 1];
    d  = orig_affine * [x_len - x_half; 1 - y_half; 1];

    a_x = a(1) + x_half;
    
    if a_x < 1
        new_height = ceil( abs(a(1)) + abs(b(1)));
        new_width = ceil(abs(d(2)) + abs(c(2)));
    else
        new_height = ceil( abs(c(1)) + abs(d(1)));
        new_width = ceil( abs(a(2)) + abs(b(2)));
    end

    x_padding = new_height - x_len;
    y_padding = new_width - y_len;
    x_half_pad = x_padding / 2;
    y_half_pad = y_padding / 2;
    
    im = zeros(x_len + x_padding, y_len + y_padding);
    
    for x = 1 : x_len + x_padding
        for y = 1 : y_len + y_padding
            % make sure the image applies the transformation on the middle
            % of the image
            old_points = affine * [x - x_half - x_half_pad; y - y_half - y_half_pad; 1];
            old_x = old_points(1) + x_half;
            old_y = old_points(2) + y_half;
            if old_x >= 1 && old_y >= 1 && old_x <= x_len && old_y <= y_len
                % nearest neighbor
                nn_x = floor(old_x + 0.5);
                nn_y = floor(old_y + 0.5);
                pixel_val = image(nn_x, nn_y);
                im(x, y) = pixel_val;
            end
        end
    end
end
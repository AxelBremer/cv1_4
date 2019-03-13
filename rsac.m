function [transformation, best_inliers] = RANSAC(matches, fa, fb, N, p)
%RANSAC Summary of this function goes here
%   Detailed explanation goes here

% Step 4. Perform RANSAC
best_count_inliers = 0;
best_inliers = [];
for n=1:N
    indices = randsample(1:size(matches, 2), p);
    matches_sample = matches(:, indices);
    A = zeros(2 * length(indices), 6);
    b = zeros(2 * length(indices), 1);
    for i=1:2:size(A, 1)
        x = fa(1:2, matches_sample(1, ceil(i / 2)));
        b(i:i+1) = fb(1:2, matches_sample(2, ceil(i / 2)));
        
        A(i,1) = x(1);
        A(i,2) = x(2);
        A(i + 1, 3) = x(1);
        A(i + 1, 4) = x(2);
        A(i, 5) = 1;
        A(i + 1, 6) = 1;
    end
    
    t = pinv(A) * b;
    coords_f1 = fa(1:2, matches(1, :));
    
    A = zeros(2 * size(coords_f1, 2), 6);
    for i=1:2:size(A, 1)
        x = coords_f1(1:2, ceil(i / 2));
        
        A(i,1) = x(1);
        A(i,2) = x(2);
        A(i + 1, 3) = x(1);
        A(i + 1, 4) = x(2);
        A(i, 5) = 1;
        A(i + 1, 6) = 1;
    end
    
    % Transform coordinates using constructed matrix A and transformation
    % params t
    transformed_coords = A * t;
    
    % Transform into similar format (first row is x1, second row is x2)
    transformed_coords = reshape(transformed_coords, 2, []); 
     
    % Determine outliers, inliers:
    cnt_inliers = 0;
    inliers = [];
    for j=1:size(transformed_coords, 2)
        d = sqrt(sum((transformed_coords(:, j) - coords_f1(:, j)) .^ 2));
        if d < 10
            cnt_inliers = cnt_inliers + 1;
            inliers = [inliers;  transformed_coords(:, j)];
        end
    end
    
    if cnt_inliers > best_count_inliers
        transformation = t;
        best_inliers = inliers;
        cnt_inliers = cnt_inliers;
    end
end
best_inliers = reshape(best_inliers, 2, []);
end
function [] = RANSAC(matches_T)

%repeat N times
N = 10;
if N > size(matches_T, 1)
    N = size(matches_T,1);
for runs=1:N
   %P random matches 
    P = 5;
    matches_P = datasample(matches_T,P,1);%last value is dim
    av_P = [mean(matches_P,1) mean(matches_P,2)];%ofzoiets
    A = [av_P(1) av_P(2) 0 0 1 0; 0 0 av_P(1) av_P(2) 0 1];
    x = zeros(6,1);%of 1x6??
    b = 
end

%from P matches make A and b:   (average the matches??? can only process one match at a time)
%A = [x y 0 0 1 0]              (or just P=1?)
%    [0 0 x y 0 1]
%x = [m1 m2 m3 m4 t1 t2]^T
%b = [x'y']^T
%solve: x = pinv(A*b)

%return transformation

%transform T points from im1
%plot with line connecting T points in im1 and im2

%count inliers (#transformed points im1 in 10 pixel radius of pair im2)

end
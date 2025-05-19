function [LP_img1, LPM] = fusion_g2(LP_img1, LP_img2, reg_size, mask_bool, nth_img, LPM)
% fuse 2 levels together based on local deviation

if nargin < 4
    mask_bool = 0;
end

if nargin < 5
    nth_img = 0;
end

if nargin < 6
    LPM = 0;
end

J = reg_size;

nhood = ones(J,J);

D1 = stdfilt(LP_img1,nhood);
D2 = stdfilt(LP_img2,nhood);

if mask_bool == 1
    mask = D2 > D1;
    if nth_img ~= 0
        LPM(mask == 1) = nth_img - 1; % sets the color of the mask
    end
else
    LPM = 0;
end
LP_img1(D2 > D1) = LP_img2(D2 > D1);

end


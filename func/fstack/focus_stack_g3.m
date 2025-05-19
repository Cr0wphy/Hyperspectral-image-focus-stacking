function [G0_fused, M] = focus_stack_g3(data, n_levels, sigma, std_radius, mask, nth_img, M)

if nargin < 4
    std_radius = 5; % size of a local area where the fusion takes place
end

if nargin < 5
    mask = 0;
end

if nargin < 6
    nth_img = 0;
end

if nargin < 7
    M = 0;
end

std_size = round(2*std_radius+1);

if max(size(data{1}))/2^n_levels < 2
    error("Too many levels of decomposition!");
end

m = floor(sigma*5); % make large enough kernel
[h1, h2] = meshgrid(-(m-1)/2:(m-1)/2, -(m-1)/2:(m-1)/2);
hg = exp(- (h1.^2+h2.^2) / (2*sigma^2));
w = hg ./ sum(hg(:));

% w = 1/256*[1 4 6 4 1; 4 16 24 16 4; 6 24 35 24 6;
%           4 16 24 16 4;1 4 6 4 1]; % convolution kernel

disp("Decomposing");
G1 = gpuArray(data{1});
[LP1,idx_p1] = decompose3(G1, n_levels, w);
clear G1

% debug, visualisation
% for i = 1:n_levels+1
%     idx_xi = idx_p1(1,1,i):idx_p1(1,2,i);
%     idx_yi = idx_p1(2,1,i):idx_p1(2,2,i);
%     plot_fft2(LP1(idx_xi,idx_yi,:), w, i);
% end
%

G2 = gpuArray(data{2});
[LP2,~] = decompose3(G2, n_levels, w);
clear data  G2; % vyčistí data

% initialize M
if mask == 1 && nargin > 5
    if M == 0
        M = zeros(size(LP1));
    end
end

disp("Fusion");
% pairwise algorithm
% inicialize
LP1_fused_end_x = idx_p1(1,1,end):idx_p1(1,2,end);
LP1_fused_end_y = idx_p1(2,1,end):idx_p1(2,2,end);


% choose pixels of the sharpest areas of both image levels
for i = 1:n_levels+1
    idx_xi = idx_p1(1,1,i):idx_p1(1,2,i);
    idx_yi = idx_p1(2,1,i):idx_p1(2,2,i);
    if mask == 1
        [LP1(idx_xi,idx_yi,:), M(idx_xi,idx_yi,:)] = fusion_g2(LP1(idx_xi,idx_yi,:), LP2(idx_xi,idx_yi,:), std_size, mask, nth_img, M(idx_xi,idx_yi,:));
    else
        LP1(idx_xi,idx_yi,:) = fusion_g2(LP1(idx_xi,idx_yi,:), LP2(idx_xi,idx_yi,:), std_size);
    end
end

% inverse transform
disp("Inverse Laplacian transform");
G0_fused = LP1(LP1_fused_end_x,LP1_fused_end_y,:);
for i = n_levels:-1:1
    G0_fused_temp = expand_g2(G0_fused,w);
    idx_xi = idx_p1(1,1,i):idx_p1(1,2,i);
    idx_yi = idx_p1(2,1,i):idx_p1(2,2,i);
    G0_fused = G0_fused_temp(1:length(idx_xi),1:length(idx_yi),:) + LP1(idx_xi,idx_yi,:);
end

G0_fused = gather(G0_fused);



end


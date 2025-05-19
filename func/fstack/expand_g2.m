function [img_new_big, img_new] = expand_g2(img, w)

N = size(img,1)*2;
M = size(img,2)*2;
C = size(img,3);

img_new = imfilter(img,w,'conv','replicate');
img_new_big = imresize(img_new,[N M],'method','bilinear','Antialiasing',0);


end


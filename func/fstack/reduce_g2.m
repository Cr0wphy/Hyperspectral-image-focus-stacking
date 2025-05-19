function [img_new_small, img_new] = reduce_g2(img, w)

N = ceil(size(img,1)/2);
M = ceil(size(img,2)/2);

img_new = imfilter(img,w,'conv','replicate');
img_new_small = imresize(img_new,[N M],'method','nearest','Antialiasing',0);


end


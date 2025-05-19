function [data_chunk_par] = chunk_interp(data_chunk_par, x_, y_)
channels = size(data_chunk_par,3);

for i = 1:channels
    data_chunk_par(:,:,i) = images.internal.interp2d(data_chunk_par(:,:,i),x_,y_,...
        "linear",mean(data_chunk_par(:,:,i)), false);
end

end


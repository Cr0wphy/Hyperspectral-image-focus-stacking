clc; clear; close all

addpath(genpath('func'));


%%% setting vars

% path for grayscale, RGB or HS image
% RGB: folder test5 includes 2 .jpg  images
data_path = '\data\demo_rgb\test5\';
% HS: folder test5 would include J folders. In these folders,
% folder "capture" of HS image is located, including .raw files

current_path = pwd;
folder_path = [current_path data_path];

n_levels = 5; % levels of decomposition, recommended: 5
sigma_w = 1.1; % default 1.1, 0.8 and less might cause aliasing
                % higher than 1.3 causes halo effects around sharp edges
std_radius = 10; % radius of a local area where the fusion takes place, 
                % square with size 2*std_radius+1, recommended: 10

channel_chunk = 16; % process a small quantity of spectral channels at a time

save_stacked = 1; stacked_name = 'stacked'; % save final image while mimicing RGB
manual_reg = 1; % load coords to manual registration and apply translation
man_T = load('data\demo_rgb\reg\trans.txt'); % path to translation coords

%%% END OF SETTINGS


% display the results
spectral_range = 600; % 400 - 1000 nm is a range of 600
blue_nm = 490; % ~max percieved by human eye
green_nm = 550; % ~max percieved by human eye
red_nm = 630; % ~max percieved by human eye
disp_channels = ([red_nm green_nm blue_nm]-400)/spectral_range;

fname_selected = struct2cell(dir(folder_path))';
fname_selected = fname_selected(3:end,1);


if exist('man_T','var') == 0
    manual_reg = 0;
end

num_pics = size(fname_selected,1);

if num_pics < 2
    error('Not enough images for a comparison');
end
data = cell(2,1);

%%%%%% MAIN ALGORITHM
tic; % check time with loading 
for i = 1:num_pics
    %%% load 2 images at a time
    disp(['Loading image ' num2str(i) '...']);
    curr_fpath = [folder_path fname_selected{i} '\capture\'];
    if i == 1
        idx = 1;
    else
        idx = 2;
    end
    
    % normal image or HS image
    if ~isempty(regexp(fname_selected{i}, '\.(jpg|png)$', 'once'))
        data{idx} = imread([folder_path fname_selected{i}]);
        data{idx} = im2double(data{idx});
        wavelengths = 1:size(data{idx},3);
        if size(data{1},3) == 3
            rgb = 1;
        else
            rgb = 0;
        end
    else
        [data{idx}, wavelengths] = hs_data_load(fname_selected{i},curr_fpath);
        rgb = 0;
    end

    %%% after loading the first image, load the second one
    % initialization stuff
    if i == 1
        channels = size(data{1},3);
        if rgb == 0
            disp_channels = round(disp_channels*channels);
        else
            disp_channels = [1 2 3];
        end
        continue;
    end
    
    save_img_path = [fileparts(fileparts(folder_path)) '\saved_images\'];
    if ~exist(save_img_path, 'dir')
        mkdir(save_img_path);
    end

    %%% only compute a few channels at a time
%     tic; % check time without loading 
    for c = 1:channel_chunk:channels
        % set indexes
        chunk = c + channel_chunk - 1;
        if chunk > channels
            chunk = channels;
        end
        disp(['Computing for channel ' num2str(c) ' all the way to channel ' num2str(chunk)]);
        data2_chunk = channel_chunk;
        if data2_chunk > size(data{2},3)
            data2_chunk = size(data{2},3);
        end

        data_chunk = {data{1}(:,:,c:chunk);data{2}(:,:,1:data2_chunk)};


        %%%% registration
        if c == 1
            if manual_reg == 1
                dx = man_T(i-1,1);
                dy = man_T(i-1,2);
                data_res = [size(data{1},2) size(data{1},1)];
                [x, y] = meshgrid(1:data_res(1), 1:data_res(2));
                x_ = x - dx;
                y_ = y + dy;
                fprintf('dx = %i, dy = %i\n', dx, dy);
                
            else
              % place an automated register algorithm here
%             [~, x_, y_] = register({data{1}(:,:,round(channels*0.8));data{2}(:,:,round(channels*0.8))}, sigma);
            end
        end

        if manual_reg == 1
            % register images by coords saved in trans.txt
            data_chunk{2} = chunk_interp(data_chunk{2}, x_, y_);
        end

        %%%% focus_stacking
        data{1}(:,:,c:chunk) = focus_stack_g3(data_chunk, n_levels, sigma_w, std_radius);
        data{2,1} = data{2,1}(:,:,channel_chunk+1:end);

    end
    toc;
end

%% END OF THE MAIN SCRIPT

if save_stacked == 1
        save_path_init = fullfile([save_img_path stacked_name]);
        save_id = 0;
        save_path = save_path_init;
        while exist([save_path '.jpg'], 'file') == 2
            save_path = [save_path_init num2str(save_id)];
            save_id = save_id + 1;
        end
        data_tosave1 = data{1}(:,:,disp_channels);
        imwrite(data_tosave1,[save_path '.jpg']);
        clear data_tosave;
end
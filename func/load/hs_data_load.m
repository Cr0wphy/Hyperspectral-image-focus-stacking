function [data, wavelengths] = hs_data_load(fname_selected,fpath)
    
    %% READ HS image
    
    [Data, info] = enviread([fpath,fname_selected,'.raw'],[fpath,fname_selected,'.hdr']);
    [White, winfo] = enviread([fpath,'WHITEREF_',fname_selected,'.raw'],[fpath,'WHITEREF_',fname_selected,'.hdr']);
    [Dark, dinfo] = enviread([fpath,'DARKREF_',fname_selected,'.raw'],[fpath,'DARKREF_',fname_selected,'.hdr']);
    
    wavelengths = str2num(info.Wavelength(2:end-1));
    
    %% Calibration
    
    HS_calibrated = zeros(size(Data));
    white_ref = mean(White, 1);
    dark_ref = mean(Dark, 1);
    
    
    for i = 1:size(Data, 1)
       HS_calibrated(i,:,:) = (Data(i,:,:) - dark_ref(1,:,:))./(white_ref(1,:,:) - dark_ref(1,:,:));
    end
     
    data = HS_calibrated;
end


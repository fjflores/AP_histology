function FF_view_aligned_histology_volume(av,slice_im_path,channel,thr,coords)
% AP_view_aligned_histology_volume(tv,av,st,slice_im_path,channel)
%
% Plot histology warped onto CCF volume
% Andy Peters (peters.andrew.j@gmail.com)
%
% channel - channel (color) to threshold and plot

% Initialize guidata
gui_data = struct;
gui_data.av = av;

% Load in slice images
gui_data.slice_im_path = slice_im_path;
slice_im_dir = dir([slice_im_path filesep '*.tif']);
slice_im_fn = natsortfiles(cellfun(@(path,fn) [path filesep fn], ...
    {slice_im_dir.folder},{slice_im_dir.name},'uni',false));
gui_data.slice_im = cell(length(slice_im_fn),1);
for curr_slice = 1:length(slice_im_fn)
    gui_data.slice_im{curr_slice} = imread(slice_im_fn{curr_slice});
end

% Load corresponding CCF slices
ccf_slice_fn = [slice_im_path filesep 'histology_ccf.mat'];
load(ccf_slice_fn);
gui_data.histology_ccf = histology_ccf;

% Load histology/CCF alignment
ccf_alignment_fn = [slice_im_path filesep 'atlas2histology_tform.mat'];
load(ccf_alignment_fn);
gui_data.histology_ccf_alignment = atlas2histology_tform;

% Warp histology to CCF
gui_data.atlas_aligned_histology = cell(length(gui_data.slice_im),1);
for curr_slice = 1:length(gui_data.slice_im)
    curr_av_slice = gui_data.histology_ccf(curr_slice).av_slices;
    curr_av_slice(isnan(curr_av_slice)) = 1;
    curr_slice_im = gui_data.slice_im{curr_slice};
    
    tform = affine2d;
    tform.T = gui_data.histology_ccf_alignment{curr_slice};
    % (transform is CCF -> histology, invert for other direction)
    tform = invert(tform);
    
    tform_size = imref2d([size(gui_data.histology_ccf(curr_slice).av_slices,1), ...
        size(gui_data.histology_ccf(curr_slice).av_slices,2)]);
    
    gui_data.atlas_aligned_histology{curr_slice} = ...
        imwarp(curr_slice_im,tform,'nearest','OutputView',tform_size);
    
end

% Create figure
gui_fig = figure( 'Color', 'w' );

% Set up 3D plot for volume viewing
switch coords
    case 'ccf'
        axes_atlas = axes;
        plotBrainGrid([],axes_atlas);
        set(axes_atlas,'ZDir','reverse');
        hold(axes_atlas,'on');
        axis vis3d equal on manual
        caxis([0 300]);
        [ap_max,dv_max,ml_max] = size(av);
        xlim([-10,ap_max+10])
        ylim([-10,ml_max+10])
        zlim([-10,dv_max+10])
        view([-30,25]);
        
    case 'pax'
        axes_atlas = plotBrainSurf( av );
        view( [ -120, 25 ] );
        
    otherwise
        error( 'Coordinates must be either ''ccf'' or ''pax''.' )
        
end



switch channel
    case 1
        colormap(brewermap([],'Reds'));
    case 2
        colormap(brewermap([],'Greens'));
    case 3
        colormap(brewermap([],'Blues'));
end

% Turn on rotation by default
h = rotate3d(axes_atlas);
h.Enable = 'on';

% Draw all aligned slices
histology_surf = gobjects(length(gui_data.slice_im),1);

if nargin < 6
    thr = 100;
    
end

for curr_slice = 1:length(gui_data.slice_im)
    
    % Get thresholded image
    curr_slice_im = gui_data.atlas_aligned_histology{curr_slice}(:,:,channel);
    thisAP = gui_data.histology_ccf(curr_slice).plane_ap;
    thisML = gui_data.histology_ccf(curr_slice).plane_ml;
    thisDV = gui_data.histology_ccf(curr_slice).plane_dv;
    
    switch coords
        case 'pax'
            bregma = allenCCFbregma();
            thisAP = ( thisAP - bregma( 1 ) ) / 100;
            thisML = ( thisML - bregma( 3 ) ) / 100;
            thisDV = ( ( thisDV - bregma( 2 ) ) / 100 ) * 0.945;
            
    end
    
    % Draw if thresholded pixels (ignore if not)
    if any(curr_slice_im(:) > thr)
        % Draw a surface at CCF coordinates
        switch coords
            case 'ccf'
                histology_surf(curr_slice) = surface(...
                    thisAP,...
                    thisML,...
                    thisDV );
                
            case 'pax'
                histology_surf(curr_slice) = surface(...
                    thisML,...
                    -thisAP,...
                    thisDV );
                
        end
        
        % Draw the slice on the surface
        histology_surf(curr_slice).FaceColor = 'texturemap';
        histology_surf(curr_slice).EdgeColor = 'none';
        histology_surf(curr_slice).CData = curr_slice_im;
        
        % Set the alpha data
        max_alpha = 1;
        slice_alpha = mat2gray(curr_slice_im,[thr,double(max(curr_slice_im(:)))])*max_alpha;
        histology_surf(curr_slice).FaceAlpha = 'texturemap';
        histology_surf(curr_slice).AlphaDataMapping = 'none';
        histology_surf(curr_slice).AlphaData = slice_alpha;
        
        drawnow;
        
    end
    
end










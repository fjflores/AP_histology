function AP_grab_histology_ccf(tv,av,st,slice_im_path)
% Grab CCF slices corresponding to histology slices
% Andy Peters (peters.andrew.j@gmail.com)

% Initialize guidata
guiData = struct;
guiData.tv = tv;
guiData.av = av;
guiData.st = st;

% Load in slice images
guiData.slice_im_path = slice_im_path;
slice_im_dir = dir( [ slice_im_path filesep '*.tif' ] );
slice_im_fn = natsortfiles(...
    cellfun( @( path,fn )...
    [ path filesep fn ],...
    { slice_im_dir.folder },{ slice_im_dir.name }, 'uni', false ) );
guiData.slice_im = cell( length( slice_im_fn ), 1 );
for curr_slice = 1 : length( slice_im_fn )
    guiData.slice_im{curr_slice} = imread(slice_im_fn{curr_slice});
    
end


% Create figure, set button functions
gui_fig = figure(...
    'WindowScrollWheelFcn', @scroll_atlas_slice, ...
    'KeyPressFcn', @keypress );

% Set up axis for histology image
guiData.histology_ax = subplot( 1, 2, 1, 'YDir', 'reverse' ); 
hold on
axis image off
curr_histology_slice = 1;
guiData.histology_im_h = image(...
    guiData.slice_im{ curr_histology_slice },...
    'Parent', guiData.histology_ax );
guiData.curr_histology_slice = curr_histology_slice;
thisSlice = slice_im_fn{ curr_histology_slice };
[ ~, fn, ext ] = fileparts( thisSlice );
fprintf( 'Slice loaded: %s\n', [ fn ext ] )
title( guiData.histology_ax, 'No saved atlas position' );

% Set up 3D atlas axis
guiData.atlas_ax = subplot( 1, 2, 2, ...
    'ZDir', 'reverse',...
    'color', 'k',...
    'XTick',[ 1, size( av, 1 ) ],...
    'XTickLabel', { 'Front', 'Back' },...
    'YTick',[ 1, size( av, 3 ) ],...
    'YTickLabel', { 'Left', 'Right' }, ...
    'ZTick', [ 1, size( av, 2 ) ],...
    'ZTickLabel', { 'Top', 'Bottom' } );
hold on
axis vis3d equal manual
view( [ 90, 0 ] );
[ ap_max, dv_max, ml_max ] = size( tv );
xlim( [ 1, ap_max ] );
ylim( [ 1, ml_max ] );
zlim( [ 1, dv_max ] );
colormap( guiData.atlas_ax, 'gray' );
caxis( [ 0, 400 ] );

% Load previously defined histology, if exists
ccfDir = fullfile( slice_im_path, 'histology_ccf.mat' );
guiData.previous = [ ];
if isfile( ccfDir )
    prompt = 'Want to load previous histology?';
    str = questdlg( prompt );
    
    if strcmpi( str, 'Yes' )
        fprintf( 'Loading histology file...' );
        load( ccfDir )
        disp( 'Done.' );
        guiData.previous = histology_ccf;
        
    else
        msg = 'Histology file not loaded.';
        disp( msg );
        
    end
    
end


% Create slice object and first slice point
guiData.atlas_slice_plot = surface( guiData.atlas_ax, 'EdgeColor', 'none' ); % Slice on 3D atlas
guiData.atlas_slice_point = camtarget;

% Set up atlas parameters to save for histology
guiData.slice_vector = nan( 1, 3 );
guiData.slice_points = nan( length( guiData.slice_im ), 3 );

% Upload gui data
guidata( gui_fig, guiData );

% Draw the first slice
update_atlas_slice( gui_fig );

% Print controls
CreateStruct.Interpreter = 'tex';
CreateStruct.WindowStyle = 'non-modal';
msgbox( ...
    {'\fontsize{12}' ...
    '\bf Controls: \rm' ...
    '1,2 : move histology slice' ...
    'Arrow keys: rotate CCF atlas', ...
    'Scroll wheel: move CCF slice in/out of plane', ...
    'Enter: set current histology and CCF slice pair', ...
    'Escape: save and close'}, ...
    'Controls',CreateStruct);

end 

function keypress(gui_fig,eventdata)

% Get guidata
guiData = guidata(gui_fig);

switch eventdata.Key
    
    % Arrow keys: rotate atlas slice
    case 'leftarrow'
        set( guiData.atlas_ax,...
            'View', get( guiData.atlas_ax, 'View' ) + [ 1, 0 ]);
        update_atlas_slice( gui_fig )
        
    case 'rightarrow'
        set( guiData.atlas_ax,...
            'View', get( guiData.atlas_ax, 'View' ) + [ -1, 0 ] );
        update_atlas_slice( gui_fig )
        
    case 'uparrow'
        set( guiData.atlas_ax,...
            'View', get(guiData.atlas_ax, 'View' ) + [ 0, -1 ] );
        update_atlas_slice( gui_fig )
        
    case 'downarrow'
        set( guiData.atlas_ax,...
            'View', get( guiData.atlas_ax, 'View' ) + [ 0, 1 ] );
        update_atlas_slice( gui_fig )
    
    % 1/2 keys: cycle through histology slices
    % (if there's a saved plane point, move atlas to that position)
    case '1'
        guiData.curr_histology_slice = max(...
            guiData.curr_histology_slice - 1, 1 );            
        guidata( gui_fig, guiData );
        update_histology_slice( gui_fig );
        if ~isempty( guiData.previous )
            update_atlas_slice( gui_fig )
            
        end
        
    case '2'
        guiData.curr_histology_slice = min(...
            guiData.curr_histology_slice + 1, length( guiData.slice_im ) );
        guidata( gui_fig, guiData );
        update_histology_slice( gui_fig );
        if ~isempty( guiData.previous )
            update_atlas_slice( gui_fig )
            
        end
        
    % Enter: save slice coordinates
    case 'return'        
        % Store camera vector and point
        % (Note: only one camera vector used for all slices, overwrites)
        guiData.slice_vector = get_camera_vector(guiData);
        guiData.slice_points(guiData.curr_histology_slice,:) = ...
            guiData.atlas_slice_point;
        guidata(gui_fig,guiData);
                
        update_histology_slice(gui_fig);
        title(guiData.histology_ax,'New saved atlas position');
        
    % Escape: save and exit
    case 'escape'
        opts.Default = 'Yes';
        opts.Interpreter = 'tex';
        user_confirm = questdlg('\fontsize{15} Save and quit?','Confirm exit',opts);
        if strcmp(user_confirm,'Yes')
            
            % Check that a CCF slice point exists for each histology slice
            if any(isnan(guiData.slice_points(:)))
                createmode = struct;
                createmode.Interpreter = 'tex';
                createmode.WindowStyle = 'modal';
                msgbox('\fontsize{12} Some histology slice(s) not assigned CCF slice', ...
                    'Not saving','error',createmode);
                return
            end
            
            % Go through each slice, pull full-resolution atlas slice and
            % corrsponding coordinates       
            histology_ccf_init = cell( length( guiData.slice_im ), 1 );
            histology_ccf = struct(...
                'tv_slices', histology_ccf_init,...
                'av_slices', histology_ccf_init,...
                'plane_ap', histology_ccf_init,...
                'plane_ml', histology_ccf_init,...
                'plane_dv', histology_ccf_init);
            
            h = waitbar( 0, 'Saving atlas slices...' );
            for curr_slice = 1 : length(guiData.slice_im)
                guiData.atlas_slice_point = guiData.slice_points( curr_slice, : );
                [ histology_ccf( curr_slice ).tv_slices,...
                    histology_ccf( curr_slice ).av_slices,...
                    histology_ccf( curr_slice ).plane_ap,...
                    histology_ccf( curr_slice ).plane_ml,...
                    histology_ccf( curr_slice ).plane_dv ] =...
                    grab_atlas_slice( guiData, 1 );
                waitbar( curr_slice / length( guiData.slice_im ), h,...
                    ['Saving atlas slices (' num2str(curr_slice) '/' num2str(length(guiData.slice_im)) ')...']);
            end                     
            close(h);
            
            save_fn = [guiData.slice_im_path filesep 'histology_ccf.mat'];
            save(save_fn,'histology_ccf','-v7.3');
            close(gui_fig);            
        end
end

end

function update_histology_slice(gui_fig)
% Draw histology slice (and move atlas if saved position)

% Get guidata
guiData = guidata(gui_fig);

% Set next histology slice
set(guiData.histology_im_h,'CData',guiData.slice_im{guiData.curr_histology_slice})

% If there's a saved atlas position, move atlas to there
if all( ~isnan( guiData.slice_points( guiData.curr_histology_slice, : ) ) )
    guiData.atlas_slice_point = ...
        guiData.slice_points( guiData.curr_histology_slice, : );
    title( guiData.histology_ax, 'Saved atlas position' )
    guidata( gui_fig, guiData );
    update_atlas_slice( gui_fig );
    
else
    title( guiData.histology_ax, 'No saved atlas position' )
end

% Upload gui data
guidata( gui_fig, guiData );

end

function cam_vector = get_camera_vector( guiData )
% Get the camera viewing vector to define atlas slice plane

% Grab current camera angle

% (Old way: more confusing, easily messed up by axes directions)
% [cam_az,cam_el] = view(guiData.atlas_ax);
% 
% % Camera azimuth is 90 degrees offset from spherical standard (?!)
% cam_az_sphere = cam_az - 90;
% % Camera elevation is reversed (because of CCF orientation)
% cam_el_sphere = -cam_el;
% 
% [cam_vector_x,cam_vector_y,cam_vector_z] = ...
%     sph2cart(deg2rad(cam_az_sphere),deg2rad(cam_el_sphere),1);
% cam_vector = [cam_vector_x,cam_vector_y,cam_vector_z];

% (New way: just a normalized line from the camera to the center)
curr_campos = campos(guiData.atlas_ax);
curr_camtarget = camtarget(guiData.atlas_ax);
cam_vector = (curr_camtarget - curr_campos)./norm(curr_camtarget - curr_campos);

end

function scroll_atlas_slice(gui_fig,eventdata)
% Move point to draw atlas slice perpendicular to the camera

% Get guidata
guiData = guidata(gui_fig);

% Move slice point along camera -> center axis
cam_vector = get_camera_vector(guiData);

% Move slice point
guiData.atlas_slice_point = guiData.atlas_slice_point + ...
    eventdata.VerticalScrollCount*cam_vector;

% Upload gui data
guidata(gui_fig, guiData);

% Update slice
update_atlas_slice(gui_fig)

end

function update_atlas_slice( guiFig )
% Draw atlas slice through plane perpendicular to camera through set point

% Get guidata
guiData = guidata( guiFig );

% Get slice (larger spacing for faster pulling)
if isempty( guiData.previous )
    [ tv_slice, av_slice, plane_ap, plane_ml, plane_dv ] = grab_atlas_slice(...
        guiData, 3 );
    
else
    currSlice = guiData.curr_histology_slice;
    [ tv_slice, av_slice, plane_ap, plane_ml, plane_dv ] = struct2var(...
        guiData.previous( currSlice ) );
    
end

% Update the slice display
set(...
    guiData.atlas_slice_plot,...
    'XData', plane_ap,...
    'YData', plane_ml,...
    'ZData', plane_dv,...
    'CData', tv_slice);

% Upload guiData
guidata(guiFig, guiData);

end

function [tv_slice,av_slice,plane_ap,plane_ml,plane_dv] = grab_atlas_slice(guiData,slice_px_space)
% Grab anatomical and labelled atlas within slice

% Get plane normal to the camera -> center axis, grab voxels on plane
cam_vector = get_camera_vector(guiData);
plane_offset = -(cam_vector*guiData.atlas_slice_point');

% Define a plane of points to index
% (the plane grid is defined based on the which cardinal plan is most
% orthogonal to the plotted plane. this is janky but it works)

[~,cam_plane] = max(abs(cam_vector./norm(cam_vector)));

switch cam_plane
    
    % Note: ML and DV directions are flipped to match 2D histology and 3D
    % atlas axes, so make ML and DV coordinates go backwards for true CCF
    % coordinates
    
    case 1
        [plane_ml,plane_dv] = ...
            meshgrid(1:slice_px_space:size(guiData.tv,3), ...
            1:slice_px_space:size(guiData.tv,2));
        plane_ap = ...
            (cam_vector(2)*plane_ml+cam_vector(3)*plane_dv + plane_offset)/ ...
            -cam_vector(1);
        
    case 2
        [plane_ap,plane_dv] = ...
            meshgrid(1:slice_px_space:size(guiData.tv,1), ...
            1:slice_px_space:size(guiData.tv,2));
        plane_ml = ...
            (cam_vector(1)*plane_ap+cam_vector(3)*plane_dv + plane_offset)/ ...
            -cam_vector(2);
        
    case 3
        [plane_ap,plane_ml] = ...
            meshgrid(size(guiData.tv,3):-slice_px_space:1, ...
            1:slice_px_space:size(guiData.tv,3));
        plane_dv = ...
            (cam_vector(1)*plane_ap+cam_vector(2)*plane_ml + plane_offset)/ ...
            -cam_vector(3);
        
end

% Get the coordiates on the plane
ap_idx = round(plane_ap);
ml_idx = round(plane_ml);
dv_idx = round(plane_dv);

% Find plane coordinates in bounds with the volume
% (CCF coordinates: [AP,DV,ML])
use_ap = ap_idx > 0 & ap_idx < size(guiData.tv,1);
use_dv = dv_idx > 0 & dv_idx < size(guiData.tv,2);
use_ml = ml_idx > 0 & ml_idx < size(guiData.tv,3);
use_idx = use_ap & use_ml & use_dv;

curr_slice_idx = sub2ind(size(guiData.tv),ap_idx(use_idx),dv_idx(use_idx),ml_idx(use_idx));

% Find plane coordinates that contain brain
curr_slice_isbrain = false(size(use_idx));
curr_slice_isbrain(use_idx) = guiData.av(curr_slice_idx) > 0;

% Index coordinates in bounds + with brain
grab_pix_idx = sub2ind(size(guiData.tv),ap_idx(curr_slice_isbrain),dv_idx(curr_slice_isbrain),ml_idx(curr_slice_isbrain));

% Grab pixels from (selected) volume
tv_slice = nan(size(use_idx));
tv_slice(curr_slice_isbrain) = guiData.tv(grab_pix_idx);

av_slice = nan(size(use_idx));
av_slice(curr_slice_isbrain) = guiData.av(grab_pix_idx);

end














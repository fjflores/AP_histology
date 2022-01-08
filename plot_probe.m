function plot_probe( tv, probe_ccf )

% Plot probe trajectories
figure( 'Name','Probe trajectories' );
axes_atlas = axes;
[ ~, brain_outline ] = plotBrainGrid( [], axes_atlas );
set( axes_atlas, 'ZDir', 'reverse' );
hold( axes_atlas, 'on' );
axis vis3d equal off manual
view( [ -30, 25 ] );
caxis( [ 0 300 ] );
[ ap_max, dv_max, ml_max ] = size( tv );
xlim( [ -10, ap_max + 10 ] )
ylim( [ -10, ml_max + 10 ] )
zlim( [ -10, dv_max + 10 ] )
h = rotate3d( gca );
h.Enable = 'on';
n_probes = length( probe_ccf );
for curr_probe = 1 : n_probes
    
    % Plot points and line of best fit
    r0 = mean( probe_ccf( curr_probe ).points, 1 );
    xyz = bsxfun( @minus, probe_ccf( curr_probe ).points, r0 );
    [ ~, ~, V ] = svd( xyz, 0 );
    histology_probe_direction = V( :, 1 );
    
    % (make sure the direction goes down in DV - flip if it's going up)
    if histology_probe_direction(2) < 0
        histology_probe_direction = -histology_probe_direction;
        
    end
    
    line_eval = [ -1000, 1000 ];
    probe_fit_line = bsxfun( @plus,...
        bsxfun( @times, line_eval', histology_probe_direction' ), r0 );
    plot3(...
        probe_ccf( curr_probe ).points( :, 1 ), ...
        probe_ccf( curr_probe ).points( :, 3 ), ...
        probe_ccf( curr_probe ).points( :, 2 ), ...
        '.',...
        'color', probe_ccf( curr_probe ).probe_color,...
        'MarkerSize', 20 );
    line(...
        probe_fit_line( :, 1 ),...
        probe_fit_line( :, 3 ),...
        probe_fit_line( :, 2 ),...
        'color', probe_ccf( curr_probe ).probe_color,...
        'linewidth', 2 )
    
end


% Plot probe areas
% figure( 'Name', 'Trajectory areas' );
% % (load the colormap - located in the repository, find by associated fcn)
% allenCCF_path = fileparts( which( 'allenCCFbregma' ) );
% cmap_filename = [ allenCCF_path filesep 'allen_ccf_colormap_2017.mat' ];
% load( cmap_filename );
% 
% for curr_probe = 1 : n_probes
%     curr_axes = subplot( 1, n_probes, curr_probe );
%     trajectory_area_boundaries = ...
%         [1;find(diff(probe_ccf(curr_probe).trajectory_areas) ~= 0);length(probe_ccf(curr_probe).trajectory_areas)];    
%     trajectory_area_centers = trajectory_area_boundaries(1:end-1) + diff(trajectory_area_boundaries)/2;
%     trajectory_area_labels = gui_data.st.safe_name(probe_ccf(curr_probe).trajectory_areas(round(trajectory_area_centers)));
%       
%     image(probe_ccf(curr_probe).trajectory_areas);
%     colormap(curr_axes,cmap);
%     caxis([1,size(cmap,1)])
%     set(curr_axes,'YTick',trajectory_area_centers,'YTickLabels',trajectory_area_labels);
%     set(curr_axes,'XTick',[]);
%     title(['Probe ' num2str(curr_probe)]);
%     
% end
function ccf_areas = plot_probe( av, probe_ccf, coords, st )
% PLOT_PROBE plots histologically-defined probe points within Allen CCF.
%
% Usage:
% plot_probe( av, probe_ccf, areas, st )
%
% Input:
% av: annotated volume data from Allen CCF.
% probe_ccf: probe location data from AP_get_probe_histology.
% coords: Optional. Defines what coordinates to use. If 'ccf' uses the
%         original common coordinate framework and a brain grid. If 'pax',
%         transforms the probe ccf coordinates to paxinos and plots a brain
%         surface. Default 'pax'.
% st: Optional. If passed, plots the brain areas spanned by the probe.
%
% Output:
% Figure with brain volume, probe start and end points, and regression line
% for the points.


% Check user input and set defaults.
if nargin < 3
    coords = 'pax';
    
end

if nargin < 4
    areas = false;
    
end

if nargin == 4
    areas = true;
    
end

% Plot either brain grid or surface.
switch coords
    case 'ccf'
        figure( 'Name','Probe trajectories' );
        axes_atlas = axes;
        plotBrainGrid( [], axes_atlas );
        set( axes_atlas, 'ZDir', 'reverse' );
        hold( axes_atlas, 'on' );
        axis vis3d equal off manual
        view( [ -30, 25 ] );
        caxis( [ 0 300 ] );
        [ ap_max, dv_max, ml_max ] = size( av );
        xlim( [ -10, ap_max + 10 ] )
        ylim( [ -10, ml_max + 10 ] )
        zlim( [ -10, dv_max + 10 ] )
        h = rotate3d( axes_atlas );
        h.Enable = 'on';
        
    case 'pax'
        figure( 'Name','Probe trajectories' );
        axes_atlas = plotBrainSurf( av, true );
        set( axes_atlas, 'ZDir', 'reverse' );
        hold( axes_atlas, 'on' );
        axis vis3d equal off manual
        view( [ -120, 25 ] );
        h = rotate3d( axes_atlas );
        h.Enable = 'on';
        probe_pax = trprobeccf( probe_ccf );
        
    otherwise
        error( 'Must provide valid coordinates, either ''pax'' or ''ccf''.' )
        
end

n_probes = length( probe_ccf );
probe_fit = cell( 1, n_probes );
for curr_probe = 1 : n_probes
    switch coords
        case 'ccf'
            thisPoints = probe_ccf( curr_probe ).points;
            
        case 'pax'
            thisPoints = probe_pax( curr_probe ).points;
            
    end
    xyz = [ thisPoints( :, 1 ), thisPoints( :, 3 ), thisPoints( :, 2 ) ];
    probe_fit{ curr_probe } = fit3d( xyz );
    
    % Plot points and line of best fit
    plot3(...
        xyz( :, 1 ), ...
        xyz( :, 2 ), ...
        xyz( :, 3 ), ...
        '.',...
        'color', probe_ccf( curr_probe ).probe_color,...
        'MarkerSize', 20 );
    line(...
        probe_fit{ curr_probe }( :, 1 ),...
        probe_fit{ curr_probe }( :, 2 ),...
        probe_fit{ curr_probe }( :, 3 ),...
        'color', probe_ccf( curr_probe ).probe_color,...
        'linewidth', 2 )
    
end


% Plot probe areas
% if areas
%     figure( 'Name', 'Trajectory areas' );
%     % (load the colormap - located in the repository, find by associated fcn)
%     allenCCF_path = fileparts( which( 'allenCCFbregma' ) );
%     cmap_filename = [ allenCCF_path filesep 'allen_ccf_colormap_2017.mat' ];
%     load( cmap_filename );
%     
%     for curr_probe = 1 : n_probes
%         curr_axes = subplot( 1, n_probes, curr_probe );
%         trajectory_area_boundaries = ...
%             [ 1;...
%             find( diff( probe_ccf( curr_probe ).trajectory_areas ) ~= 0 );...
%             length( probe_ccf( curr_probe ).trajectory_areas ) ];
%         trajectory_area_centers =...
%             trajectory_area_boundaries( 1 : end - 1) +...
%             diff( trajectory_area_boundaries ) / 2;
%         areaCent = round( trajectory_area_centers );
%         trajectory_area_labels =...
%             st.safe_name(...
%             probe_ccf( curr_probe ).trajectory_areas( areaCent ) );
%         
%         image( probe_ccf( curr_probe ).trajectory_areas );
%         colormap( curr_axes, cmap );
%         caxis( [ 1, size( cmap, 1 ) ] )
%         set( curr_axes,...
%             'YTick', trajectory_area_centers,...
%             'YTickLabels', trajectory_area_labels );
%         set(curr_axes,'XTick',[]);
%         title(['Probe ' num2str(curr_probe)]);
%         
%     end
%     
% end

% get areas at the tip of the probe
ccf_areas = cell( n_probes, 1 );
for curr_probe = 1 : n_probes
    thisPoints = probe_ccf( curr_probe ).points;
    xyz = [ thisPoints( :, 1 ), thisPoints( :, 3 ), thisPoints( :, 2 ) ];
    probe_fit = fit3d( xyz );
    ccf_areas{ curr_probe, 1 } = get_areas( probe_fit, av, st );
    
end

function xyzEst = fit3d( xyz )

xyzHat = mean( xyz, 1 );
A = xyz - xyzHat;
N = length( A );
C = ( A' * A ) / ( N - 1 );
[ R, ~, ~ ] = svd( C, 0 );
x = A * R( :, 1 );    % project residuals on R(:,1)
xMin = min( x );
xMax = max( x );
dx = xMax - xMin;
Xa = ( xMin + 0.01 * dx ) * R( :, 1 )' + xyzHat;
Xb = ( xMax + 0.05 * dx ) * R( :, 1 )' + xyzHat;
xyzEst = [ Xa; Xb ];
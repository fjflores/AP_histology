function plot_probe( av, probe_ccf, coords, areas )
% PLOT_PROBE plots histologically-defined probe points within Allen CCF.
%
% Usage:
% plot_probe( tv, probe_ccf, areas )
%
% Input:
% tv: annotated volume data from Allen CCF.
% probe_ccf: probe location data from AP_get_probe_histology.
% coords: (Opt.) what coordinates to use. If 'ccf' uses the original common 
%         coordinate framework and a brain grid. If 'pax', transfomrs the 
%         probe ccf coordinates to paxinos and plots a brain surface.
%         Default 'pax'.
% areas: (Opt.) If true, plots the brain areas spanned by the probe.
%        Default 'false'.
%
% Output:
% Figure with brain volume, probe start and end points, and regression line
% for the points.


% Check user input.
if nargin < 3
    coords = 'pax';
    
end

if nargin < 4
    areas = false;
    
end

% Plot probe trajectories
switch coords
    case 'ccf'
        figure( 'Name','Probe trajectories' );
        axes_atlas = axes;
        [ ~, brain_outline ] = plotBrainGrid( [], axes_atlas );
        set( axes_atlas, 'ZDir', 'reverse' );
        hold( axes_atlas, 'on' );
        axis vis3d equal off manual
        view( [ -30, 25 ] );
        caxis( [ 0 300 ] );
        [ ap_max, dv_max, ml_max ] = size( av );
        xlim( [ -10, ap_max + 10 ] )
        ylim( [ -10, ml_max + 10 ] )
        zlim( [ -10, dv_max + 10 ] )
        h = rotate3d( gca );
        h.Enable = 'on';
        
    case 'pax'
        axes_atlas = plotBrainSurf( av, true );
        set( axes_atlas, 'ZDir', 'reverse' );
        hold( axes_atlas, 'on' );
        axis vis3d equal off manual
        view( [ -30, 25 ] );
        probe_ccf = trprobeccf( probe_ccf );
        
    otherwise
        error( 'Must provide valid coordinates, either ''pax'' or ''ccf''.' )
        
end

n_probes = length( probe_ccf );
for curr_probe = 1 : n_probes
    thisPoints = probe_ccf( curr_probe ).points;
    xyz = [ thisPoints( :, 1 ), thisPoints( :, 3 ), thisPoints( :, 2 ) ];
    probe_fit_line = fit3d( xyz );
    
    % Plot points and line of best fit
    plot3(...
        xyz( :, 1 ), ...
        xyz( :, 2 ), ...
        xyz( :, 3 ), ...
        '.',...
        'color', probe_ccf( curr_probe ).probe_color,...
        'MarkerSize', 20 );
    line(...
        probe_fit_line( :, 1 ),...
        probe_fit_line( :, 2 ),...
        probe_fit_line( :, 3 ),...
        'color', probe_ccf( curr_probe ).probe_color,...
        'linewidth', 2 )
    
end


% Plot probe areas
if areas
    figure( 'Name', 'Trajectory areas' );
    % (load the colormap - located in the repository, find by associated fcn)
    allenCCF_path = fileparts( which( 'allenCCFbregma' ) );
    cmap_filename = [ allenCCF_path filesep 'allen_ccf_colormap_2017.mat' ];
    load( cmap_filename );
    
    for curr_probe = 1 : n_probes
        curr_axes = subplot( 1, n_probes, curr_probe );
        trajectory_area_boundaries = ...
            [1;find(diff(probe_ccf(curr_probe).trajectory_areas) ~= 0);length(probe_ccf(curr_probe).trajectory_areas)];
        trajectory_area_centers = trajectory_area_boundaries(1:end-1) + diff(trajectory_area_boundaries)/2;
        trajectory_area_labels = gui_data.st.safe_name(probe_ccf(curr_probe).trajectory_areas(round(trajectory_area_centers)));
        
        image(probe_ccf(curr_probe).trajectory_areas);
        colormap(curr_axes,cmap);
        caxis([1,size(cmap,1)])
        set(curr_axes,'YTick',trajectory_area_centers,'YTickLabels',trajectory_area_labels);
        set(curr_axes,'XTick',[]);
        title(['Probe ' num2str(curr_probe)]);
        
    end
    
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
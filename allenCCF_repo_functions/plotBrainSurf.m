function axes_atlas = plotBrainSurf( av, rel )

if nargin < 2
    rel = true;
    
end

if rel
    % Coordinates in millimeters relative to bregma
    % (bregma AP/ML is estimated from comparing the Paxinos atlas to the CCF atlas)
    % (bregma DV is estimated from comparing MRI to CCF - very rough estimate)
    % [AP,DV,ML]
    %
    % (NOTE: non-uniform scaling, DV in CCF is stretched. The DV scaling factor
    % has been approximated by comparisons to in vivo MRI images)
    
    bregma_ccf = [540,44,570];
    ap_coords = -( ( 1 : size( av, 1 ) ) - bregma_ccf( 1 ) ) / 100;
    dv_coords = ( ( ( 1 : size( av, 2 ) ) - bregma_ccf( 2 ) ) / 100 ) * 0.945;
    ml_coords = -( ( 1 : size( av, 3 ) ) - bregma_ccf( 3 ) ) / 100;
    
else
    ap_coords = -( 1 : size( av, 1 ) );
    dv_coords = 1 : size( av, 2 );
    ml_coords = -( 1 : size( av, 3 ) );
    
end


% Set up the atlas axes
% axes_atlas = axes('Position',[-0.3,0.1,1.2,0.8],'ZDir','reverse');
axes_atlas = axes( 'ZDir','reverse' );
axis( axes_atlas, 'vis3d', 'equal', 'off', 'manual' );
hold( axes_atlas, 'on' );

% Draw brain outline
slice_spacing = 10; % 10 um
brain_volume = ...
    bwmorph3( bwmorph3( av( 1 : slice_spacing : end, ...
    1 : slice_spacing : end, 1 : slice_spacing : end ) > 1, 'majority' ), 'majority' );

[ curr_ml_grid, curr_ap_grid, curr_dv_grid ] = ...
    ndgrid( ml_coords( 1 : slice_spacing : end ), ...
    ap_coords( 1 : slice_spacing : end ), dv_coords( 1 : slice_spacing : end ) );

brain_outline_patchdata = reducepatch(...
    isosurface( curr_ml_grid, curr_ap_grid,...
    curr_dv_grid, permute( brain_volume, [ 3, 1, 2 ]), 0.5 ), 0.1 );

brain_outline = patch( ...
    'Vertices', brain_outline_patchdata.vertices,...
    'Faces', brain_outline_patchdata.faces,...
    'FaceColor', [0.5,0.5,0.5],...
    'EdgeColor', 'none',...
    'FaceAlpha', 0.1 );

view([30,150]);
caxis([0 300]);

xlim([min(ml_coords),max(ml_coords)])
ylim([min(ap_coords),max(ap_coords)])
zlim([min(dv_coords),max(dv_coords)])
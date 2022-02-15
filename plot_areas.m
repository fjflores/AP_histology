function plot_areas( areaCCF, av, sliceSp, axAtlas )
% PLOT_AREAS plot a specific brain areas from Allen CCF.
% 
% Usage:
% plot_areas( sphynxId, av, st, sliceSp, axAtlas )
% 
% Input:
% areaCCF: structure with at least structure_id_path and color_hex fields.
% av: annotated volume.
% sliceSp: Optional. decimation factor for AV.
% axAtlas: Optional. axes to plot to.
% 
% Output:
% Axes with volume plot of the desired structure.


% Set up slice spacing.
if nargin < 4 || isempty( sliceSp )
    sliceSp = 5;
    
end

% Set up the atlas axes.
if nargin < 5
    axAtlas = axes( 'ZDir', 'reverse' );

end
rotate3d( axAtlas, 'on' )
axis( axAtlas, 'vis3d', 'equal', 'off' );

% Get guidata.
bregma = allenCCFbregma;
apCoords = -( ( 1 : size( av, 1 ) ) - bregma( 1 ) ) / 100;
dvCoords = ( ( ( 1 : size( av, 2 ) ) - bregma( 2 ) ) / 100 ) * 0.85;
mlCoords = -( ( 1 : size( av, 3 ) ) - bregma( 3 ) ) / 100;

% Get all areas within and below the selected hierarchy level.
structId = areaCCF.structure_id_path;
ccfIdx = find(...
    cellfun( @( x ) contains( x, structId ),...
    areaCCF.structure_id_path ) );

% Generate plotting grid.
[ mlGrid, apGrid, dvGrid ] = ndgrid(...
    mlCoords( 1 : sliceSp : end ),...
    apCoords( 1 : sliceSp : end ), ...
    dvCoords( 1 : sliceSp : end ) );

% Decimate AV.
decAv = av( 1 : sliceSp : end, 1 : sliceSp : end, 1 : sliceSp : end );
shuffAv = permute( ismember( decAv, ccfIdx ), [ 3, 1, 2 ] );
struct3d = isosurface( mlGrid, apGrid, dvGrid, shuffAv, 0 );

% Plot the brain region.
structAlpha = 0.2;
patch( axAtlas, ...
    'Vertices', struct3d.vertices, ...
    'Faces', struct3d.faces, ...
    'FaceColor', areaCCF.color_rgb,...
    'EdgeColor', 'none',...
    'FaceAlpha', structAlpha);
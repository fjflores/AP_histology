function plot_areas( sphynx_id, av, st, sliceSp, axAtlas )

% Set up slice spacing
if nargin < 4 || isempty( sliceSp )
    sliceSp = 5;
    
end

% Set up the atlas axes
if nargin < 5
    axAtlas = axes( 'ZDir', 'reverse' );

end
rotate3d( axAtlas, 'on' )
axis( axAtlas, 'vis3d', 'equal', 'off' );

% Get guidata
bregma = allenCCFbregma;
apCoords = -( ( 1 : size( av, 1 ) ) - bregma( 1 ) ) / 100;
dvCoords = ( ( ( 1 : size( av, 2 ) ) - bregma( 2 ) ) / 100 ) * 0.85;
mlCoords = -( ( 1 : size( av, 3 ) ) - bregma( 3 ) ) / 100;

% Get all areas within and below the selected hierarchy level
structId = st.structure_id_path{ sphynx_id };
ccfIdx = find(...
    cellfun( @( x ) contains( x, structId ),...
    st.structure_id_path ) );

% plot the structure
structColor = hex2dec(...
    reshape( st.color_hex_triplet{ sphynx_id }, 2, [ ] )' ) ./ 255;
[ mlGrid, apGrid, dvGrid ] = ndgrid(...
    mlCoords( 1 : sliceSp : end ),...
    apCoords( 1 : sliceSp : end ), ...
    dvCoords( 1 : sliceSp : end ) );

% decimate AV
decAv = av( 1 : sliceSp : end, 1 : sliceSp : end, 1 : sliceSp : end );
shuffAv = permute( ismember( decAv, ccfIdx ), [ 3, 1, 2 ] );
struct3d = isosurface( mlGrid, apGrid, dvGrid, shuffAv, 0 );

structAlpha = 0.2;
patch( axAtlas, ...
    'Vertices', struct3d.vertices, ...
    'Faces', struct3d.faces, ...
    'FaceColor', structColor',...
    'EdgeColor', 'none',...
    'FaceAlpha', structAlpha);
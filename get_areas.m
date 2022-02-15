function areaCCF = get_areas( probe_fit, av, st )

% find row with max depth
[ ~, maxIdx] = max( probe_fit( :, 3 ) );


bottomPts = probe_fit( maxIdx, : );
ccf_points_cat = round( bottomPts );

% Get indicies from subscripts. Remember ccf is AP, DV, ML.
ccf_points_idx = sub2ind(...
    size( av ),...
    ccf_points_cat( :, 1 ),...
    ccf_points_cat( :, 3 ),...
    ccf_points_cat( :, 2 ) );

% Find annotated volume (AV) values at points
ccf_points_av = av( ccf_points_idx );

% Get areas from the structure tree (ST) at given AV values
areaCCF.name = st( ccf_points_av, : ).safe_name{ 1 };
areaCCF.acronym = st( ccf_points_av, : ).acronym{ 1 };
areaCCF.sphinx_id = st( ccf_points_av, : ).sphinx_id( 1 );
areaCCF.parent_id = st( ccf_points_av, : ).parent_structure_id( 1 );
rgb = hex2rgb( st( ccf_points_av, : ).color_hex_triplet{ 1 } );
areaCCF.color_rgb = rgb ./ 255;


    

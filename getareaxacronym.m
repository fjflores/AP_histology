function areaCCF = getareaxacronym( acronym, st )

% % find row with max depth
% [ ~, maxIdx] = max( probe_fit( :, 3 ) );
% bottomPts = probe_fit( maxIdx, : );
% ccf_points_cat = round( bottomPts );
% 
% % Get indicies from subscripts. Remember ccf is AP, DV, ML.
% ccf_points_idx = sub2ind(...
%     size( av ),...
%     ccf_points_cat( :, 1 ),...
%     ccf_points_cat( :, 3 ),...
%     ccf_points_cat( :, 2 ) );
% 
% % Find annotated volume (AV) values at points
% acroIdx = av( ccf_points_idx );

% Search for acronym idx
acroIdx = st( strcmpi( st.acronym, acronym ), : ).sphinx_id;

% Get areas from the structure tree (ST) at given AV values
areaCCF.name = st( acroIdx, : ).safe_name{ 1 };
areaCCF.acronym = st( acroIdx, : ).acronym{ 1 };
areaCCF.id = st( acroIdx, : ).id;
areaCCF.atlas_id = st( acroIdx, : ).atlas_id;
areaCCF.sphinx_id = st( acroIdx, : ).sphinx_id;
areaCCF.parent_id = st( acroIdx, : ).parent_structure_id;
areaCCF.structure_id_path = st( acroIdx, : ).structure_id_path;
areaCCF.color_hex = st( acroIdx, : ).color_hex_triplet{ 1 };
rgb = hex2rgb( areaCCF.color_hex );
areaCCF.color_rgb = rgb ./ 255;


    

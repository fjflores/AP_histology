function draw_areas(probe_atlas_gui,slice_spacing,plot_structure)

% Get guidata
gui_data = guidata(probe_atlas_gui);

if ~isempty(plot_structure)
    
    % Get all areas within and below the selected hierarchy level
    plot_structure_id = gui_data.st.structure_id_path{plot_structure};
    plot_ccf_idx = find(cellfun(@(x) contains(x,plot_structure_id), ...
        gui_data.st.structure_id_path));
    
    % plot the structure
    slice_spacing = 5;
    plot_structure_color = hex2dec(reshape(gui_data.st.color_hex_triplet{plot_structure},2,[])')./255;
    
    [curr_ml_grid,curr_ap_grid,curr_dv_grid] = ...
    ndgrid(gui_data.ml_coords(1:slice_spacing:end), ...
    gui_data.ap_coords(1:slice_spacing:end), ...
    gui_data.dv_coords(1:slice_spacing:end));
    
    structure_3d = isosurface(curr_ml_grid,curr_ap_grid,curr_dv_grid, ...
        permute(ismember(gui_data.av(1:slice_spacing:end, ...
        1:slice_spacing:end,1:slice_spacing:end),plot_ccf_idx),[3,1,2]),0);
    
    structure_alpha = 0.2;
    gui_data.structure_plot_idx(end+1) = plot_structure;
    gui_data.handles.structure_patch(end+1) = patch(gui_data.handles.axes_atlas, ...
        'Vertices',structure_3d.vertices, ...
        'Faces',structure_3d.faces, ...
        'FaceColor',plot_structure_color,'EdgeColor','none','FaceAlpha',structure_alpha);
    
end
function [init_dim_table, final_dim_table, structure_table, rootChord, tipChord, halfSpan, diameter, totalLength, A_ref, inertiaRoll] = rocketBuildup()
    %% Constants
    rootChord = 20; % in 17
    tipChord = 10; % in 10.859
    halfSpan = 6.5; % in 5
    inertiaRoll = 0.2; % kg m^2
    diameter = 6.4; % in
    totalLength = 138.6982; % in
    A_ref = pi*(diameter/2).^2;

    %% Mass Data 
    % Add any component with significant mass
    % Format: init_dim_table{i, :} = [Start X_dist (in), End X_dist, Start OD, End OD, Mass (lbs)]
    init_dim_table = table();
    init_dim_table{1, :} = [0, 7.4458, 0, 1.4355, 1.3328]; % Tip
    init_dim_table{2, :} = [7.4458, 33.0731, 1.4355, 6.4, 4.5428]; % Nosecone
    init_dim_table{3, :} = [33.0732, 45.0732, 6.4, 6.4, 2.7644]; % Shoulder
    init_dim_table{4, :} = [45.0732, 49.0732, 6.4, 6.4, 15.6/16]; % Switchband
    init_dim_table{5, :} = [38.5728, 55.4478, 6, 6, 10.12]; % AV Bay
    init_dim_table{6, :} = [49.0732, 61.0732, 6.4, 6.4, 3.0813]; % Recovery Airframe
    init_dim_table{7, :} = [55.6982, 64.6982, 6, 6, 5.5088]; % Motor Bulkhead
    init_dim_table{8, :} = [61.0728, 138.0728, 6.4, 6.4, 26.76]; % Motor Casing
    init_dim_table{9, :} = [64.7, 87.7, 6, 6, 27.676]; % Grain 1
    init_dim_table{10, :} = [87.7, 98.7, 6, 6, 12.830]; % Grain 2
    init_dim_table{11, :} = [98.7, 109.7, 6, 6, 12.450]; % Grain 3
    init_dim_table{12, :} = [109.7, 120.95, 6, 6, 12.424]; % Grain 4
    init_dim_table{13, :} = [120.95, 132.2, 6, 6, 11.774]; % Grain 5
    init_dim_table{14, :} = [133.6982, 138.6982, 6, 6, 5.72]; % Nozzle
    init_dim_table{15, :} = [138.0728-rootChord-3, 138.0728-3, 6.4, 6.4+halfSpan, 2.45375*4]; % Fins
    
    final_dim_table = table();
    final_dim_table{1, :} = [0, 7.4458, 0, 1.4355, 1.3328]; % Nosecone Tip
    final_dim_table{2, :} = [7.4458, 33.0731, 1.4355, 6.4, 4.5428]; % Nosecone
    final_dim_table{3, :} = [33.0732, 45.0732, 6.4, 6.4, 2.7644]; % Shoulder
    final_dim_table{4, :} = [45.0732, 49.0732, 6.4, 6.4, 15.6/16]; % Switchband
    final_dim_table{5, :} = [38.5728, 55.4478, 6, 6, 10.12]; % AV Bay
    final_dim_table{6, :} = [49.0732, 61.0732, 6.4, 6.4, 3.0813]; % Recovery Airframe
    final_dim_table{7, :} = [55.6982, 64.6982, 6, 6, 5.5088]; % Motor Bulkhead
    final_dim_table{8, :} = [61.0728, 138.0728, 6.4, 6.4, 26.76]; % Motor Casing
    final_dim_table{9, :} = [64.7, 87.7, 6, 6, 0.5]; % Grain 1
    final_dim_table{10, :} = [87.7, 98.7, 6, 6, 0.5]; % Grain 2
    final_dim_table{11, :} = [98.7, 109.7, 6, 6, 0.5]; % Grain 3
    final_dim_table{12, :} = [109.7, 120.95, 6, 6, 0.5]; % Grain 4
    final_dim_table{13, :} = [120.95, 132.2, 6, 6, 0.5]; % Grain 5
    final_dim_table{14, :} = [133.6982, 138.6982, 6, 6, 5.72]; % Nozzle
    final_dim_table{15, :} = [135.0728-rootChord, 135.0728, 6.4, 6.4+halfSpan, 2.45375*4]; % Fins
    
    init_dim_table = renamevars(init_dim_table, ["Var1", "Var2", "Var3", "Var4", "Var5"], ["X0", "XF", "D0", "DF", "M"]);
    final_dim_table = renamevars(final_dim_table, ["Var1", "Var2", "Var3", "Var4", "Var5"], ["X0", "XF", "D0", "DF", "M"]);
    
    init_dim_table{:, 1:4} = init_dim_table{:, 1:4}/39.37;
    init_dim_table{:, 5} = init_dim_table{:, 5}/2.207;
    
    final_dim_table{:, 1:4} = final_dim_table{:, 1:4}/39.37;
    final_dim_table{:, 5} = final_dim_table{:, 5}/2.207;

    %% Structure Data (Composites make E inaccurate)
    % Add all components making up airframe or rocket body
    % Format: stucture_table{i, :} = [Start X_dist (in), End X_dist, Start OD, End OD, Thickness, Young's Mod (Pa)]
    structure_table = table();
    structure_table{1, :} = [0, 7.4458, 1/32, 1.4355, 1, 69E9]; % Nosecone Tip
    structure_table{2, :} = [7.4458, 33.0731, 1.4355 - 1/8, 6, 3/16, 24E9]; % Nosecone (1/8 cork)
    structure_table{3, :} = [33.0732, 45.0732, 6, 6, 0.2, 49E9]; % Shoulder (Assuming all load on coupler)
    structure_table{4, :} = [45.0732, 49.0732, 6.4, 6.4, 0.4, 24E9]; % Switchband
    structure_table{5, :} = [49.0732, 61.0732, 6, 6, 0.2, 24E9]; % Recovery Airframe (Assuming all load on coupler)
    % structure_table{6, :} = [32.25, 66.25, 6.4, 6.4, .2, 45E9]; % Main Airframe 
    % structure_table{6, :} = [38, 38+17, 6, 6, .25, 45E9]; % Coupler
    structure_table{6, :} = [55.6982, 64.6982, 6.4, 6.4, 0.25, 69E9]; % Motor Coupler
    structure_table{7, :} = [61.0728, 138.6982, 6.4, 6.4, 0.2, 27E9]; % Motor Casing

    structure_table = renamevars(structure_table, ["Var1", "Var2", "Var3", "Var4", "Var5", "Var6"], ["X0", "XF", "D0", "DF", "Thick", "E"]);
    structure_table{:, 1:5} = structure_table{:, 1:5}/39.37;
end
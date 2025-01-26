function [init_dim_table, final_dim_table, structure_table, POIs, rootChord, tipChord, halfSpan, diameter, totalLength, A_ref, inertiaRoll] = rocketBuildup()
    %% Constants
    rootChord = 20; % in 17
    tipChord = 10; % in 10.859
    halfSpan = 6.5; % in 5
    inertiaRoll = 0.2; % kg m^2
    diameter = 6.46; % in
    totalLength = 146.0408; % in
    A_ref = pi*(diameter/2).^2;

    %% Positions of Interest
    POIs = [40.5138, 57.6388, 70.5138]; % in from tip

    %% Mass Data 
    % Add any component with significant mass
    % Format: init_dim_table{i, :} = [Start X_dist (in), End X_dist, Start OD, End OD, Mass (lbs)]
    init_dim_table = table();
    init_dim_table{1, :} = [0, 7.4458, 0, 1.4355, 1.3328]; % Tip
    init_dim_table{2, :} = [7.4458, 33.5138, 1.4355, 6.46, 4.5428]; % Nosecone
    init_dim_table{3, :} = [33.5138, 47.0138, 6.46, 6.46, 2.7644]; % Shoulder
    init_dim_table{4, :} = [47.0138, 51.0138, 6.46, 6.46, 15.6/16]; % Switchband
    init_dim_table{5, :} = [40.5138, 57.6388, 6, 6, 10.12]; % AV Bay
    init_dim_table{6, :} = [51.0138, 67.0138, 6.46, 6.46, 3.0813]; % Recovery Airframe
    init_dim_table{7, :} = [62.5138, 71.5138, 6, 6, 5.5088]; % Motor Bulkhead
    init_dim_table{8, :} = [67.0138, 145.0138, 6.46, 6.46, 26.76]; % Motor Casing
    init_dim_table{9, :} = [72.3908, 95.3908, 6, 6, 39.676]; % Grain 1
    init_dim_table{10, :} = [95.3908, 106.3908, 6, 6, 9.830]; % Grain 2
    init_dim_table{11, :} = [106.3908, 117.3908, 6, 6, 9.450]; % Grain 3
    init_dim_table{12, :} = [117.3908, 128.3908, 6, 6, 9.424]; % Grain 4
    init_dim_table{13, :} = [128.3908, 140.3888, 6, 6, 8.774]; % Grain 5
    init_dim_table{14, :} = [140.3888, totalLength, 6, 6, 5.72]; % Nozzle
    init_dim_table{15, :} = [142.1298-rootChord, 142.1298, 6.46, 6.46+halfSpan, 2.45375*4]; % Fins
    
    final_dim_table = table();
    final_dim_table{1, :} = [0, 7.4458, 0, 1.4355, 1.3328]; % Tip
    final_dim_table{2, :} = [7.4458, 33.5138, 1.4355, 6.46, 4.5428]; % Nosecone
    final_dim_table{3, :} = [33.5138, 47.0138, 6.46, 6.46, 2.7644]; % Shoulder
    final_dim_table{4, :} = [47.0138, 51.0138, 6.46, 6.46, 15.6/16]; % Switchband
    final_dim_table{5, :} = [40.5138, 57.6388, 6, 6, 10.12]; % AV Bay
    final_dim_table{6, :} = [51.0138, 67.0138, 6.46, 6.46, 3.0813]; % Recovery Airframe
    final_dim_table{7, :} = [62.5138, 71.5138, 6, 6, 5.5088]; % Motor Bulkhead
    final_dim_table{8, :} = [67.0138, 145.0138, 6.46, 6.46, 26.76]; % Motor Casing
    final_dim_table{9, :} = [72.3908, 95.3908, 6, 6, 2.5]; % Grain 1
    final_dim_table{10, :} = [95.3908, 106.3908, 6, 6, 0.5]; % Grain 2
    final_dim_table{11, :} = [106.3908, 117.3908, 6, 6, 0.5]; % Grain 3
    final_dim_table{12, :} = [117.3908, 128.3908, 6, 6, 0]; % Grain 4
    final_dim_table{13, :} = [128.3908, 140.3888, 6, 6, 0]; % Grain 5
    final_dim_table{14, :} = [140.3888, totalLength, 6, 6, 4.72]; % Nozzle
    final_dim_table{15, :} = [142.1298-rootChord, 142.1298, 6.46, 6.46+halfSpan, 2.45375*4]; % Fins
    
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
    structure_table{2, :} = [7.4458, 33.5138, 1.4355 - 1/8, 6, 3/16, 24E9]; % Nosecone (1/8 cork)
    structure_table{3, :} = [33.5138, 47.0138, 6, 6, 0.2, 49E9]; % Shoulder (Assuming all load on coupler)
    structure_table{4, :} = [47.0138, 51.0138, 6.46, 6.46, 0.4, 24E9]; % Switchband
    structure_table{5, :} = [51.0138, 67.0138, 6, 6, 0.2, 24E9]; % Recovery Airframe (Assuming all load on coupler)
    % structure_table{6, :} = [32.25, 66.25, 6.46, 6.46, .2, 45E9]; % Main Airframe 
    % structure_table{6, :} = [38, 38+17, 6, 6, .25, 45E9]; % Coupler
    structure_table{6, :} = [62.5138, 71.5138, 6.46, 6.46, 0.25, 69E9]; % Motor Coupler
    structure_table{7, :} = [67.0138, 145.0138, 6.46, 6.46, 0.2, 27E9]; % Motor Casing

    structure_table = renamevars(structure_table, ["Var1", "Var2", "Var3", "Var4", "Var5", "Var6"], ["X0", "XF", "D0", "DF", "Thick", "E"]);
    structure_table{:, 1:5} = structure_table{:, 1:5}/39.37;
end
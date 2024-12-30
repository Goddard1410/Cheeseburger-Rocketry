function [accelAxial, accelNormal, alpha] = accelerations(distFNormal, totalFAxial, totalFNormal, totalMass, x_nose_tip, cg, I_m)
    % All units in metric FINS borked
    accelAxial = totalFAxial./totalMass;
    accelNormal = totalFNormal./totalMass;
    x_nose_tip_remap = repmat(x_nose_tip, length(cg), 1)';

    x_rel_cg = x_nose_tip_remap - cg;
    moments = distFNormal.*x_rel_cg;

    momentNet = zeros(1, length(cg));
    for i = 1:length(cg)
        momentNet(i) = trapz(x_nose_tip_remap(:,i), moments(:,i));
    end

    alpha = momentNet./I_m;
end
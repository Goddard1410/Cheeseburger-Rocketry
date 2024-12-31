function [N, V, M] = internalForces(distFNormal, distFAxial, dmdx, cg, alpha, accelAxial, accelNormal, x_nose_tip)
    sectionMass = zeros(length(x_nose_tip), length(cg));
    N = zeros(length(x_nose_tip), length(cg));
    V = zeros(length(x_nose_tip), length(cg));
    M = zeros(length(x_nose_tip), length(cg));

    for i = 1:length(cg)
        sectionMass(:,i) = cumtrapz(x_nose_tip, dmdx(:,i), 1);
        
        N(:,i) = -cumtrapz(x_nose_tip, distFAxial(:,i), 1) + accelAxial(i).*sectionMass(:,i);
        V(:,i) = -cumtrapz(x_nose_tip, distFNormal(:,i), 1) + accelNormal(i).* ...
            sectionMass(:,i) + (alpha(i).*cumtrapz(x_nose_tip, dmdx(:,i).*(x_nose_tip-cg(i))', 1));
        M(:,i) = cumtrapz(x_nose_tip, V(:,i));
    end
end


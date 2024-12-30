function [natFreq, dampingRatio] = pitchCalc(rc, tc, halfSpan, diameter, cg, finDeflection, maxSpeed, max_q, mach, inertiaLong)
    %% Constants
    diameter = diameter * 0.0254; % in to m
    A_ref = pi*(diameter/2).^2;
    cp = 108*0.0254; % m from tip
    Cna = 11.37; % From RAS Aero

    %% Natural Frequency in Pitch
    C1 = max_q.*A_ref.*Cna.*(abs(cp-cg)); % Corrective moment coefficient

    natFreq = sqrt(C1./inertiaLong); % rad/sec

    %% Damping Ratio
    % C2 = max_q./maxSpeed.*A_ref.*sum(); % Damping moment coefficient
    
    dampingRatio = 0;
    % dampingRatio = C2./(2*sqrt(C1))
end


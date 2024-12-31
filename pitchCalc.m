function [natFreq, dampingRatio] = pitchCalc(A_ref, cg, q, I_m, flightData, aeroData)
    % All units metric
    %% Constants
    A_ref = A_ref*0.00064516; % in^2 to m^2

    natFreq = zeros(1,length(flightData.Time_sec_));
    dampingRatio = zeros(1,length(flightData.Time_sec_));
    for i = 1:length(flightData.Time_sec_)
        if (flightData.MachNumber(i) < 1.05)
            natFreq(i) = 0;
            dampingRatio(i) = 0;
        else
            cp = aeroData(round(round(flightData.MachNumber(i),2).*100), 3)*0.0254; % in to m
            Cna = aeroData(round(round(flightData.MachNumber(i),2).*100), 4); % From RAS Aero, per rad
        
            %% Natural Frequency in Pitch
            C1 = q(i).*A_ref.*Cna.*(abs(cp-cg(i))); % Corrective moment coefficient
        
            natFreq(i) = sqrt(C1./I_m(i)); % rad/sec
        
            %% Damping Ratio
            % C2 = max_q./maxSpeed.*A_ref.*sum(); % Damping moment coefficient
            
            dampingRatio(i) = 0;
            % dampingRatio = C2./(2*sqrt(C1))
        end
    end
end


function [distFAxial, distFNormal, totalFAxial, totalFNormal] = aeroDistribution(init_dim_table, dx, x_nose_tip, tBurn, flightData, aeroData, q, A_ref)
    % All units in metric FINS ARE WEIRD RN
    noseconeLength = table2array(init_dim_table(2,"XF")) - table2array(init_dim_table(1,"X0"));
    bodyLength = table2array(init_dim_table(8,"XF")) - table2array(init_dim_table(2,"XF"));
    finLength = table2array(init_dim_table(15,"XF")) - table2array(init_dim_table(15,"X0"));
    
    indexNosecone = round(noseconeLength/dx);
    indexBody = round((noseconeLength+bodyLength-finLength)/dx);
    indexFin = round((noseconeLength+bodyLength)/dx);

    aeroData = aeroData(105:end,:);
    
    A_ref = A_ref * 0.00064516; % in^2 to m^2

    %% Axial Distribution
    totalFAxial = zeros(1, length(flightData.Time_sec_));
    for i = 1:length(flightData.Time_sec_)
        if (flightData.MachNumber(i) < 1.05)
            totalFAxial(i) = 0;
            totalFAxial(i) = flightData.Thrust_lb_(i)'*4.44822 - totalFAxial(i); % N
        elseif (flightData.Time_sec_(i) < tBurn(end))
            totalFAxial(i) = aeroData(round(round(flightData.MachNumber(i),2).*100), 8).*A_ref.*q(i); % N
            totalFAxial(i) = flightData.Thrust_lb_(i)'*4.44822 - totalFAxial(i); % N
        else
            totalFAxial(i) = aeroData(round(round(flightData.MachNumber(i),2).*100), 7).*A_ref.*q(i); % N
            totalFAxial(i) = -totalFAxial(i); % N
        end
    end
    distFAxialMach = zeros(length(x_nose_tip), length(aeroData(:,1)));

    % Nosecone
    noseconeCA = noseconeLength/(noseconeLength+bodyLength).*aeroData(:,9) + aeroData(:,10);
    for i = 1:indexNosecone
        distFAxialMach(i,:) = (2*noseconeCA/noseconeLength).*x_nose_tip(i);
    end

    % Body
    bodyCA = bodyLength/(noseconeLength+bodyLength).*aeroData(:,9) + aeroData(:,12);
    for i = indexNosecone+1:indexBody
        distFAxialMach(i,:) = bodyCA/bodyLength;
    end

    % Fins
    finCA = aeroData(:,13)+aeroData(:,14)+aeroData(:,15)+aeroData(:,16);
    for i = indexBody+1:indexFin
        distFAxialMach(i,:) = finCA./finLength;
    end

    %% Normal Distribution
    totalFNormal = zeros(1, length(flightData.Time_sec_));
    for i = 1:length(flightData.Time_sec_)
        if (flightData.MachNumber(i) < 1.05)
            totalFNormal(i) = 0;
        elseif (flightData.Time_sec_(i) < tBurn(end))
            totalFNormal(i) = aeroData(round(round(flightData.MachNumber(i),2).*100), 6).*A_ref.*q(i); % N
        else
            totalFNormal(i) = aeroData(round(round(flightData.MachNumber(i),2).*100), 5).*A_ref.*q(i); % N
        end
    end
    distFNormalMach = zeros(length(x_nose_tip), length(aeroData(:,1)));

    % Nosecone
    CN = aeroData(:,5);
    coeffs(1,:) = 3*(2.*CN.*noseconeLength+2.*CN.*bodyLength+CN*finLength-2*CN.*(aeroData(:,3).*0.0254))./...
        (2*noseconeLength+6*bodyLength+3*finLength);
    coeffs(2,:) = -2*(2.*CN.*noseconeLength-3.*CN.*(aeroData(:,3).*0.0254))./...
        (2*noseconeLength+6*bodyLength+3*finLength);

    for i = 1:indexNosecone
        distFNormalMach(i,:) = 2*coeffs(1,:)./(noseconeLength.^2).*x_nose_tip(i);
    end

    % Fins
    for i = indexBody+1:indexFin
        distFNormalMach(i,:) = coeffs(2,:)./finLength;
    end

    %% Aero Distribution at Mach and Time
    distFAxial = zeros(length(x_nose_tip), length(flightData.Time_sec_));
    distFNormal = zeros(length(x_nose_tip), length(flightData.Time_sec_));
    for i = 1:length(flightData.Time_sec_)
        if (flightData.MachNumber(i) < 1.05)
            distFAxial(:,i) = 0;
            distFNormal(:,i) = 0;
        else
            distFAxial(:,i) = -distFAxialMach(:,round(round(flightData.MachNumber(i),2).*100))*A_ref.*q(i);
            distFNormal(:,i) = distFNormalMach(:,round(round(flightData.MachNumber(i),2).*100))*A_ref.*q(i);
        end
    end
end


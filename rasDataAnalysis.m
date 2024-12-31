function [flightData, aeroData] = rasDataAnalysis(aeroFilename, flightFilename)
    % All units imperial
    flightData = readtable(flightFilename);

    aeroRaw = readmatrix(aeroFilename, "Delimiter", ["   ", "  "] );
    aeroRaw(isnan(aeroRaw(:,1)), :) = [];
    
    % To find Mach # reference index Mach # * 100
    aeroData = zeros(length(aeroRaw)/6, 8);
    for i = 1:length(aeroRaw)/6
        aeroData(i,1) = aeroRaw(i*6,1); % Mach #
        aeroData(i,2) = aeroRaw(i*6,2); % AoA
        aeroData(i,3) = aeroRaw(i*6-2,4); % CP
        aeroData(i,4) = aeroRaw(i*6-4,2); % CN-Alpha (per rad)
        aeroData(i,5) = aeroRaw(i*6-1,5); % CN Power Off
        aeroData(i,6) = aeroRaw(i*6,5); % CN Power On
        aeroData(i,7) = aeroRaw(i*6-1,6); % CA Power Off
        aeroData(i,8) = aeroRaw(i*6,6); % CA Power On
        aeroData(i,9) = aeroRaw(i*6-5,5); % Body Friction
        aeroData(i,10) = aeroRaw(i*6-5,6); % Nose Cone Wave
        aeroData(i,11) = aeroRaw(i*6-5,7); % Body Base
        aeroData(i,12) = aeroRaw(i*6-5,12); % Body Wave
        aeroData(i,13) = aeroRaw(i*6-5,8); % Fin Friction
        aeroData(i,14) = aeroRaw(i*6-5,9); % Fin Wave
        aeroData(i,15) = aeroRaw(i*6-5,10); % Fin Interference
        aeroData(i,16) = aeroRaw(i*6-5,11); % Fin Base
        aeroData(i,17) = aeroRaw(i*6-5,13); % Protuberance
        % aeroData(i,18) = aeroRaw(i*6-5,14); % Reynolds Number is really broken for some reason
    end
end
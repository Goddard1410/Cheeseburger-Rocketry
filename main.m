clc;
clear;
close all;
warning('off','all')

%% RAS Data
[flightData, aeroData] = rasDataAnalysis("RASData/CDDataAoA8.txt", "RASData/Flight Data.csv");

%% Dynamic Pressure
[~, SoS, ~, airDensity] = atmosisa(flightData.Altitude_ft_*0.3048);
vel = flightData.MachNumber.*SoS; % m/s
q = 0.5.*airDensity.*vel.^2; % Pa
[max_q, max_qIndex] = max(q);
max_qVel = vel(max_qIndex);
max_qMach = flightData.MachNumber(max_qIndex);

figure
subplot(2,1,1)
hold on
grid on
title("Dynamic Pressure")
xlabel("Time (sec)")
ylabel("Pressure (Pa)")
plot(flightData.Time_sec_(1:250), q(1:250))

subplot(2,1,2)
hold on
grid on
title("Altitude")
xlabel("Time (sec)")
ylabel("Altitude (ft)")
plot(flightData.Time_sec_, flightData.Altitude_ft_)
print('./Plots/Flight/Alt and Dyn Press','-dpng','-r300')

%% Mass Data
[init_dim_table, final_dim_table, structure_table, rootChord, tipChord, halfSpan, diameter, totalLength, A_ref, inertiaRoll, inertiaLong] = rocketBuildup;

%% Distribution
totalLength = totalLength/39.37;
totalBurnTime = 9.2; % sec
res = 200;
dx = totalLength/res;
x_nose_tip = linspace(0, totalLength, res);
tBurn = linspace(0, totalBurnTime, res);

%% Mass Distribution
tic
% CHANGE HOW THIS WORKS WITH TIME
[dmdx, cg, totalMass, I_m] = massDistribution(init_dim_table, final_dim_table, res, dx, x_nose_tip, tBurn);

[tBurnSurf, tipDistSurf] = meshgrid(tBurn, x_nose_tip*39.37);

animateSurf(tBurnSurf, tipDistSurf, dmdx*2.207, ...
    "Mass Distribution at Time (sec): ", ...
    ["Distance from Nose Tip (in)", "Mass (lbs)"], ...
    "./Plots/Mass Distro/Mass Distro Vid")

figure
hold on
grid on
surf(tBurnSurf, tipDistSurf, dmdx*2.207)
title("Mass Distribution During Flight")
xlabel("Time (sec)")
ylabel("Distance from Nose Tip (in)")
zlabel("Mass (lbs)")
shading interp
view(-55,8)
print('./Plots/Mass Distro/Mass Distro Surf','-dpng','-r300')

figure
subplot(2,1,1)
title("Total Mass During Flight")
xlabel("Time (sec)")
ylabel("Total Mass (lbs)")
hold on
grid on
plot(tBurn, totalMass*2.207)

subplot(2,1,2)
title("CG During Flight")
xlabel("Time (sec)")
ylabel("Distance from Nose Tip (in)")
hold on
grid on
plot(tBurn, cg*39.37)
print('./Plots/Mass Distro/Total Mass and CG','-dpng','-r300')

% Convert mass to standardized timestep
dmdxTotTime = zeros(res, length(flightData.Time_sec_));
for i = 1:res
   dmdxTotTime(i,:) = [interp1(tBurn, dmdx(i,:)', flightData.Time_sec_(1:timeIndex(flightData.Time_sec_, totalBurnTime)), "spline")', ...
      zeros(1, length(flightData.Time_sec_) - timeIndex(flightData.Time_sec_, totalBurnTime)) + dmdx(i,end)'];
end

totalMass = [interp1(tBurn, totalMass, flightData.Time_sec_(1:timeIndex(flightData.Time_sec_, totalBurnTime)), "spline")', ...
    zeros(1, length(flightData.Time_sec_) - timeIndex(flightData.Time_sec_, totalBurnTime)) + totalMass(end)];
cgTotTime = [interp1(tBurn, cg, flightData.Time_sec_(1:timeIndex(flightData.Time_sec_, totalBurnTime)), "spline")', ...
    zeros(1, length(flightData.Time_sec_) - timeIndex(flightData.Time_sec_, totalBurnTime)) + cg(end)];
I_m = [interp1(tBurn, I_m, flightData.Time_sec_(1:timeIndex(flightData.Time_sec_, totalBurnTime)), "spline")', ...
    zeros(1, length(flightData.Time_sec_) - timeIndex(flightData.Time_sec_, totalBurnTime)) + I_m(end)];

massRuntime = toc

[flightTimeSurf, tipDistSurf] = meshgrid(flightData.Time_sec_(1:250), x_nose_tip*39.37);

%% Cross Sectional Properties
tic
[crsSecInertia, crsSecArea, crsSecE, crsSecOuterRadius, crsSecZ] = crossSectionProp(structure_table, dx, res);

crossSectionRuntime = toc

%% Aero Distribution
% I Think we have fin issues imo uhhhhhhh
tic
[distFAxial, distFNormal, totalFAxial, totalFNormal] = aeroDistribution(init_dim_table, dx, x_nose_tip, tBurn, flightData, aeroData, q, A_ref);

% figure
% hold on
% grid on
% title("Axial Distribution R")
% xlabel("Distance from Nose Tip (in)")
% ylabel("Force (N)")
% plot(x_nose_tip*39.37, distFAxial(:,max_qIndex))
% 
% figure
% hold on
% grid on
% title("Normal Distribution R")
% xlabel("Distance from Nose Tip (in)")
% ylabel("Force (N)")
% plot(x_nose_tip*39.37, distFNormal(:,max_qIndex))

aeroRuntime = toc

%% Accelerations
tic
[accelAxial, accelNormal, alpha] = accelerations(distFNormal, totalFAxial, totalFNormal, totalMass, x_nose_tip, cgTotTime, I_m);

figure
hold on
grid on
title("Axial Accel During Flight")
xlabel("Time (sec)")
ylabel("Accel (m/s^2)")
plot(flightData.Time_sec_(1:250), accelAxial(:,1:250))
plot(flightData.Time_sec_(1:250), flightData.Accel_ft_sec_2_(1:250)/3.28084)
print('./Plots/Accel/Axial Accel','-dpng','-r300')

figure
hold on
grid on
title("Normal Accel During Flight")
xlabel("Time (sec)")
ylabel("Accel (m/s^2)")
plot(flightData.Time_sec_(1:250), accelNormal(:,1:250))
print('./Plots/Accel/Normal Accel','-dpng','-r300')

accelRuntime = toc

%% Internal Forces
tic
[N, V, M] = internalForces(distFNormal, distFAxial, dmdxTotTime, cgTotTime, alpha, accelAxial, accelNormal, x_nose_tip);

[NMax, indexNMax] = max(abs(N(:)));
[~,NMaxCol] = ind2sub(size(N), indexNMax);
figure
hold on
grid on
title("Max Normal Force")
xlabel("Distance from Nose Tip (in)")
ylabel("Force (N)")
plot(x_nose_tip*39.37, N(:,NMaxCol))
print('./Plots/Force/Max Normal Force','-dpng','-r300')

[VMax, indexVMax] = max(abs(V(:)));
[~,VMaxCol] = ind2sub(size(V), indexVMax);
figure
hold on
grid on
title("Max Shear Force")
xlabel("Distance from Nose Tip (in)")
ylabel("Force (N)")
plot(x_nose_tip*39.37, V(:,VMaxCol))
print('./Plots/Force/Max Shear Force','-dpng','-r300')

[MMax, indexMMax] = max(abs(M(:)));
[~,MMaxCol] = ind2sub(size(M), indexMMax);
figure
hold on
grid on
title("Max Moment")
xlabel("Distance from Nose Tip (in)")
ylabel("Moment (N-m)")
plot(x_nose_tip*39.37, M(:,MMaxCol))
print('./Plots/Force/Max Moment','-dpng','-r300')

animateSurf(flightTimeSurf, tipDistSurf, N(:,1:250), ...
    "Normal Force at Time (sec): ", ...
    ["Distance from Nose Tip (in)", "Force (N)"], ...
    "./Plots/Force/Normal Force Vid")

figure
hold on
grid on
title("Normal Force During Flight")
xlabel("Time (sec)")
ylabel("Distance from Nose Tip (in)")
zlabel("Force (N)")
surf(flightTimeSurf, tipDistSurf, N(:,1:250))
shading interp
view(-55,8)
print('./Plots/Force/Normal Force Surf','-dpng','-r300')

animateSurf(flightTimeSurf, tipDistSurf, V(:,1:250), ...
    "Shear Force at Time (sec): ", ...
    ["Distance from Nose Tip (in)", "Force (N)"], ...
    "./Plots/Force/Shear Force Vid")

figure
hold on
grid on
title("Shear Force During Flight")
xlabel("Time (sec)")
ylabel("Distance from Nose Tip (in)")
zlabel("Force (N)")
surf(flightTimeSurf, tipDistSurf, V(:,1:250))
shading interp
view(-55,8)
print('./Plots/Force/Shear Force Surf','-dpng','-r300')

animateSurf(flightTimeSurf, tipDistSurf, M(:,1:250), ...
    "Moment at Time (sec): ", ...
    ["Distance from Nose Tip (in)", "Moment (Nm)"], ...
    "./Plots/Force/Moment Vid")

figure
hold on
grid on
title("Moment During Flight")
xlabel("Time (sec)")
ylabel("Distance from Nose Tip (in)")
zlabel("Moment (Nm)")
surf(flightTimeSurf, tipDistSurf, M(:,1:250))
shading interp
view(-55,8)
print('./Plots/Force/Moment Surf','-dpng','-r300')

internalForceRuntime = toc

%% Internal Stresses
tic
[sigmaNormal, sigmaBending, tau] = internalStresses(N, V, M, crsSecArea, crsSecZ);

[sigmaNMax, indexSigmaNMax] = max(abs(sigmaNormal(:)));
[~, sigmaNMaxCol] = ind2sub(size(sigmaNormal), indexSigmaNMax);
figure
hold on
grid on
title("Max Normal Stress")
xlabel("Distance from Nose Tip (in)")
ylabel("\sigma (psi)")
plot(x_nose_tip*39.37, sigmaNormal(:,sigmaNMaxCol)/6895)
print('./Plots/Stress/Max Normal Stress','-dpng','-r300')

[sigmaBMax, indexSigmaBMax] = max(abs(sigmaBending(:)));
[~, sigmaBMaxCol] = ind2sub(size(sigmaBending), indexSigmaBMax);
figure
hold on
grid on
title("Max Bending Stress")
xlabel("Distance from Nose Tip (in)")
ylabel("\sigma (psi)")
plot(x_nose_tip*39.37, -sigmaBending(:,sigmaBMaxCol)/6895)
print('./Plots/Stress/Max Bending Stress','-dpng','-r300')

[tauMax, indexTauMax] = max(abs(tau(:)));
[~, tauMaxCol] = ind2sub(size(tau), indexTauMax);
figure
hold on
grid on
title("Max Shear Stress")
xlabel("Distance from Nose Tip (in)")
ylabel("\tau (psi)")
plot(x_nose_tip*39.37, tau(:,tauMaxCol)/6895)
print('./Plots/Stress/Max Shear Stress','-dpng','-r300')

animateSurf(flightTimeSurf, tipDistSurf, sigmaNormal(:,1:250)/6895, ...
    "Normal Stress at Time (sec): ", ...
    ["Distance from Nose Tip (in)", "\sigma (psi)"], ...
    "./Plots/Stress/Normal Stress Vid")

figure
hold on
grid on
title("Normal Stress During Flight")
xlabel("Time (sec)")
ylabel("Distance from Nose Tip (in)")
zlabel("\sigma (psi)")
surf(flightTimeSurf, tipDistSurf, sigmaNormal(:,1:250)/6895)
shading interp
view(-55,8)
print('./Plots/Stress/Normal Stress Surf','-dpng','-r300')

animateSurf(flightTimeSurf, tipDistSurf, sigmaBending(:,1:250)/6895, ...
    "Bending Stress at Time (sec): ", ...
    ["Distance from Nose Tip (in)", "\sigma (psi)"], ...
    "./Plots/Stress/Bending Stress Vid")

figure
hold on
grid on
title("Bending Stress During Flight")
xlabel("Time (sec)")
ylabel("Distance from Nose Tip (in)")
zlabel("\sigma (psi)")
surf(flightTimeSurf, tipDistSurf, -sigmaBending(:,1:250)/6895)
shading interp
view(-55,8)
print('./Plots/Stress/Bending Stress Surf','-dpng','-r300')

animateSurf(flightTimeSurf, tipDistSurf, tau(:,1:250)/6895, ...
    "Shear Stress at Time (sec): ", ...
    ["Distance from Nose Tip (in)", "\tau (psi)"], ...
    "./Plots/Stress/Shear Stress Vid")

figure
hold on
grid on
title("Shear Stress During Flight")
xlabel("Time (sec)")
ylabel("Distance from Nose Tip (in)")
zlabel("\tau (psi)")
surf(flightTimeSurf, tipDistSurf, tau(:,1:250)/6895)
shading interp
view(-55,8)
print('./Plots/Stress/Shear Stress Surf','-dpng','-r300')

internalStressRuntime = toc

%% Deflection
tic
[nu, dnudx] = deflection(abs(M), crsSecE, crsSecInertia, x_nose_tip, cg, dx);

[nuMax, indexNuMax] = max(abs(nu(:)));
[~, nuMaxCol] = ind2sub(size(nu), indexNuMax);
figure
hold on
grid on
title("Max Deflection")
xlabel("Distance from Nose Tip (in)")
ylabel("Deflection (in)")
plot(x_nose_tip*39.37, nu(:,nuMaxCol)*39.37)
print('./Plots/Deflection/Max Deflection','-dpng','-r300')

animateSurf(flightTimeSurf, tipDistSurf, nu(:,1:250)*39.37, ...
    "Deflection at Time (sec): ", ...
    ["Distance from Nose Tip (in)", "Deflection (in)"], ...
    "./Plots/Deflection/Deflection Vid")

figure
hold on
grid on
title("Deflection During Flight")
xlabel("Time (sec)")
ylabel("Distance from Nose Tip (in)")
zlabel("Deflection (in)")
surf(flightTimeSurf, tipDistSurf, nu(:,1:250)*39.37)
shading interp
view(-55,8)
print('./Plots/Deflection/Deflection Surf','-dpng','-r300')

deflectionRuntime = toc

%% Roll Rate
tic
% Expected Deflection Angle Dist
sampleNum = 1000;
confidentOffset = 0.15 * 0.0254; % net fin deflection 99% sure
deflectionAngleStd = atan2d(confidentOffset,rootChord)/2.6; % 1 std from 0
deflectionAngleDist = deflectionAngleStd*randn(1,sampleNum);
deflectionAngleDist = linspace(0,1.5,sampleNum);

[~,val,~] = rollCalc(rootChord, tipChord, halfSpan, diameter, deflectionAngleDist, max_qVel, max_q, max_qMach);

[momentDist, maxRollRate, omega] = rollCalc(rootChord, tipChord, halfSpan, diameter, deflectionAngleDist, max_qVel, max_q, max_qMach);
[finDeflectionSurf, omegaSurf] = meshgrid(deflectionAngleDist, omega/360);

[~, maxRollRate2, ~] = rollCalc(17, 10, 5, diameter, deflectionAngleDist, max_qVel, max_q, max_qMach);

figure
hold on
grid on
surf(finDeflectionSurf, omegaSurf, momentDist)
plot3(deflectionAngleDist, maxRollRate, zeros(size(deflectionAngleDist)), LineWidth=2, Color="k");
title("Net Moment at Fin Deflection and Angular Velocity")
xlabel("Fin Deflection (Degrees)")
ylabel("Angular Velocity (revs/sec)")
zlabel("Net Moment (Nm)")
shading interp
legend("Moment", "Max Roll Rate")

figure
hold on
grid on
title("Max Roll Rate")
xlabel("Fin Deflection (Degrees)")
ylabel("Angular Velocity (rad/sec)")
p1 = plot(deflectionAngleDist, maxRollRate(1,:)*2*pi, "r", LineWidth=2);
p2 = plot(deflectionAngleDist, maxRollRate2(1,:)*2*pi, "k", LineWidth=2);
legend("Mamba 3 Fins", "Mamba 1 Fins")

rollRuntime = toc

%% Pitch Rate
tic
[natFreq, dampingRatio] = pitchCalc(rootChord, tipChord, halfSpan, diameter, cg, deflectionAngleDist, max_qVel, max_q, max_qMach, inertiaLong);

figure
hold on
grid on
title("Pitch Natural Frequency")
xlabel("Time (sec)")
ylabel("Natural Frequency (rad/s)")
plot(tBurn, natFreq)
xline(8.3, "k--")
legend("Nat Freq", "Max Q", Location="northwest")

pitchRuntime = toc
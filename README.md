# Cheeseburger Rocketry
 Rocket structual calcs for ameture applications, built to integrate with RAS Aero II's aero data.

## How to Use
1. Input rocket characteristics into 'rocketBuildup.m'
    Mass data (initial and final) and airframe structural data
2. Create file structure (Plots and RASData parent folders)
    Plots/Accel, Deflecton, Flight, Force, Mass Distro, Pitch, Roll, Stress
    RASData
3. Input RAS Aero II data for rocket
    Flight Simulation export as Flight Data
    Tools -> Run Test at various AoAs for CDDataAoA
4. Set up 'main.m'
    Specify locations of CDDataAoA file and Flight Data file in RAS Data section
    Specify showPlots, plotTime, animationTime, and res in Controlables section
6. Run main.m, plots will automatically be placed in directories set up in step 2


function [momentDist, maxRollRate, omega] = rollCalc(rc, tc, halfSpan, diameter, finDeflection, maxSpeed, max_q, mach)
    %% Constants
    rc = rc * 0.0254; % Root Chord in to m
    tc = tc * 0.0254; % Tip Chord in to m
    halfSpan = halfSpan * 0.0254; % in to m
    diameter = diameter * 0.0254; % in to m
    MAC = rc * 2/3 * ((1+tc/rc+(tc/rc).^2)/(1+tc/rc));
    MACSpanwiseLoc = integral(@(x) rc*x-(rc-tc)/halfSpan*x.^2, 0, halfSpan) / ...
        integral(@(x) rc-(rc-tc)/halfSpan*x, 0, halfSpan);
    A_f = tc*halfSpan + 0.5*(rc-tc)*halfSpan;
    A_ref = pi*(diameter/2).^2;
    L_ref = diameter;
    AR = halfSpan.^2/A_ref;

    %% Forcing Moment
    beta = sqrt(mach.^2-1);
    midchordLineSweepAngle = atan2d(halfSpan, rc/2-tc/2);
    C_na1 = (2*pi*AR*(A_f/A_ref))/(2+sqrt(4+(beta*AR/cosd(midchordLineSweepAngle)).^2));
    
    M_f = 4*(MACSpanwiseLoc+diameter/2)*C_na1.*finDeflection.*max_q.*A_ref;

    %% Damping Moment
    omega = linspace(0,15000, 100);

    C_ldw = (2*4*C_na1)/(A_ref*L_ref.^2).*cosd(finDeflection).*...
            halfSpan/12.*((rc+3*tc)*halfSpan.^2+4*(rc+2*tc)*halfSpan*(diameter/2)+...
            6*(rc+tc)*(diameter/2).^2);
    
    M_d = zeros(size(finDeflection));

    for i = 1:length(omega)
        M_f(i,:) = M_f(1,:);
        M_d(i,:) = max_q*A_ref*L_ref.*C_ldw.*omega(i).*L_ref/(2*maxSpeed);
    end

    maxRollRate = M_f./(max_q*A_ref*L_ref.*C_ldw.*L_ref/(2*maxSpeed))/360; % revs/sec
    momentDist = M_f-M_d;
end

% rollDist = maxSpeed*sind(deflectionAngleDist/4)/(diameter/2 + MACSpanwiseLoc)*pi/180; % rad/s

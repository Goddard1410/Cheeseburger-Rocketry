function [nu, dnudx] = deflection(M, E, I, x_nose_tip, cg, dx)
    cgIndex = round(cg/dx);
    
    nu = zeros(size(M));
    for i = 1:length(cgIndex)
        integral1st = cumtrapz(x_nose_tip, M(:,i)./E./I);
        C1 = -integral1st(cgIndex(i));
        integral1st = integral1st + C1;
        dnudx = integral1st + C1;

        integral2nd = cumtrapz(x_nose_tip, integral1st);
        C2 = -integral2nd(cgIndex(i));
        integral2nd = integral2nd + C2;
        nu(:,i) = integral2nd;
    end
end
function [I, A, E, R, Z] = crossSectionProp(struct_table, dx, res)
    I_temp = zeros(res, height(struct_table));
    A_temp = zeros(res, height(struct_table));
    E_temp = zeros(res, height(struct_table));
    R_temp = zeros(res, height(struct_table));
    Z_temp = zeros(res, height(struct_table));
    
    for i = 1:height(struct_table)
        length = struct_table.XF(i) - struct_table.X0(i);
        indexStart = round(struct_table.X0(i)/dx) + 1;
        indexEnd = round(struct_table.XF(i)/dx);
        x_range = linspace(0, length, indexEnd-indexStart+1);

        OD = (struct_table.DF(i)-struct_table.D0(i))./length.*x_range +...
            struct_table.D0(i);
        ID = OD - 2*struct_table.Thick(i);
        ID(ID < 0) = 0;

        I_temp(indexStart:indexEnd, i) = pi*(OD.^4-ID.^4)/64;
        A_temp(indexStart:indexEnd, i) = pi*(OD.^2-ID.^2)/4;
        E_temp(indexStart:indexEnd, i) = struct_table.E(i);
        R_temp(indexStart:indexEnd, i) = OD/2;
        % Section modulus (Z) is I/y in sigma = My/I
        Z_temp(indexStart:indexEnd, i) = I_temp(indexStart:indexEnd, i)./(OD'/2);
    end

    I_temp(I_temp == 0) = NaN;
    A_temp(A_temp == 0) = NaN;
    E_temp(E_temp == 0) = NaN;
    R_temp(R_temp == 0) = NaN;
    Z_temp(Z_temp == 0) = NaN;
    I = min(I_temp, [], 2);
    A = min(A_temp, [], 2);
    E = min(E_temp, [], 2);
    R = min(R_temp, [], 2);
    Z = min(Z_temp, [], 2);
end
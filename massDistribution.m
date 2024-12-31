function [dmdx, cg, totalMass, I_m] = massDistribution(init_dim_table, final_dim_table, res, dx, x_nose_tip, t_burn)
    % Mass distribution
    dmdx = zeros(res, res);
    cg = zeros(1,res);
    I_m = zeros(1,res);
    totalMass = zeros(1,res);
    dim_table = table();
    
    for i = 1:height(init_dim_table)
        dim_table{i,1:4} = init_dim_table{i,1:4};

        mass_diff = final_dim_table.M(i)-init_dim_table.M(i);
        slopeMass = mass_diff/t_burn(end);
        dim_table{i, 5} = (init_dim_table.M(i)+slopeMass.*t_burn);
    end
 
    for t = 1:res
        dim_table_dt = table();
        for k = 1:height(dim_table)
            dim_table_dt{k,1:4} = dim_table{k,1:4};
            dim_table_dt{k, 5} = dim_table{k, 5}(1, t);
        end
        
        dmdx(:, t) = massDistributionDT(dim_table_dt, res, dx);
        cg(t) = trapz(x_nose_tip, dmdx(:, t).*x_nose_tip')./trapz(x_nose_tip', dmdx(:, t));
        I_m(t) = trapz(x_nose_tip, dmdx(:, t).*(x_nose_tip'-cg(t)).^2);
        totalMass(t) = trapz(x_nose_tip, dmdx(:,t));
    end   

    % Outputs in kg
    function [dmdxdt] = massDistributionDT(dim_table, res, dx)
        dim_table = renamevars(dim_table, ["Var1", "Var2", "Var3", "Var4", "Var5"], ["X0", "XF", "D0", "DF", "M"]);
        dmdxdt = zeros(res, 1);

        for j = 1:height(dim_table)
            %Find index of relevant elements
            len = dim_table.XF(j)-dim_table.X0(j);
            index_start = round(dim_table.X0(j)/dx)+1;
            index_end = round(dim_table.XF(j)/dx);
            elements = index_end-index_start+1;
            
            %Find radii of relevant elements
            R0 = dim_table.D0(j)/2;
            RF = dim_table.DF(j)/2;
            
            %Area of trapezoidal dist. and rectangular contribution
            a_tp = (R0+RF)/2*len;
            a_r = R0*len;
            
            %Find component contribution to mass distribution
            m = dim_table.M(j);
            m_r = a_r/a_tp*m;
            h_r = m_r/len;
            m_t = m-m_r;
            h_t = 2*m_t/len;
            slope = ((h_t+h_r)-h_r)/len;
            
            %Create vector of mass distribution of component
            x_temp = linspace(0, len, elements);
            dmdx_comp = (h_r+slope.*x_temp);
            
            %Add mass distribution to vector
            dmdxdt(index_start:index_end) = dmdxdt(index_start:index_end)+dmdx_comp';
        end
    end
end
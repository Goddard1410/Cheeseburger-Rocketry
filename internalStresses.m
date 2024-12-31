function [sigmaNormal, sigmaBending, tau] = internalStresses(N, V, M, A, Z)
    % All units in metric
    sigmaNormal = N./A;
    sigmaBending = M./Z; % Z is section modulus
    tau = 2.*V./A; % Not sure why double
end
function animateSurf(X, Y, Z, plotTitle, axisLabels, filename)
    % Incraments over time slices (X axis)
    % Initialize the figure
    fig = figure;
    hold on
    grid on
    title(plotTitle + "0")
    xlabel(axisLabels(1))
    ylabel(axisLabels(2))
    ylim([min(Z(:)), max(Z(:))]); % Adjust Z limits as necessary
    xlim([min(Y(:)), max(Y(:))]); % Adjust Y limits as necessary
    
    % Define the number of x-slices
    numXSlices = width(X);
    
    % Animation loop
    videoWriter = VideoWriter(filename, "MPEG-4");
    open(videoWriter)

    for i = 1:numXSlices
        % Extract the current y-slice (fix y and get corresponding x and z values)
        ySlice = Y(:, i);
        zSlice = Z(:, i);
    
        % Plot the x-z slice
        cla; % Clear previous frame
        title(plotTitle + X(1,i))
        plot(ySlice, zSlice);
        drawnow; % Update the figure window
        writeVideo(videoWriter, getframe(fig))
    end    

    close(videoWriter)
end
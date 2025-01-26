function animateSurf(X, Y, Z, plotTitle, axisLabels, filename, animationTime, POIs)
    % Incraments over time slices (X axis)
    fps = 30;
    totalFrames = animationTime * fps;

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
    frameTimes = linspace(1, numXSlices, totalFrames);
    
    % Animation loop
    videoWriter = VideoWriter(filename, "MPEG-4");
    videoWriter.FrameRate = fps;
    open(videoWriter)

    for i = 1:totalFrames
        % Interpolate the current frame's slice
        currentIndex = frameTimes(i);
        lowerIndex = floor(currentIndex);
        upperIndex = ceil(currentIndex);
        
        % Linear interpolation if between slices
        if lowerIndex == upperIndex || upperIndex > numXSlices
            ySlice = Y(:, lowerIndex);
            zSlice = Z(:, lowerIndex);
        else
            alpha = currentIndex - lowerIndex;
            ySlice = (1 - alpha) * Y(:, lowerIndex) + alpha * Y(:, upperIndex);
            zSlice = (1 - alpha) * Z(:, lowerIndex) + alpha * Z(:, upperIndex);
        end
    
        % Plot the x-z slice
        cla; % Clear previous frame
        title(plotTitle + X(1,lowerIndex))
        plot(ySlice, zSlice);
        if exist('POIs','var') == 1
            for i = 1:length(POIs)
                xline(POIs(i))
            end
        end
        drawnow; % Update the figure window
        writeVideo(videoWriter, getframe(fig))
    end    

    close(videoWriter)
end
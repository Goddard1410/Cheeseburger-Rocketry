function index = timeIndex(timeVec, targetTime)
    closest = timeVec(end);
    index = length(timeVec);
    for i = 1:length(timeVec)
        if (abs(targetTime-timeVec(i)) < closest)
            closest = abs(targetTime-timeVec(i));
            index = i;
        end
    end
end
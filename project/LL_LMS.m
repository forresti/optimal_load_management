
function config = LL_LMS(sensors, constants)

    %TODO: get optimal config from HL_LMS
    
    %optConfig = HL_LMS(sensors, constants)
    %isSafe = checkSafety(optConfig);
    %if isSafe
    %   config = optConfig;
    %else
        config = applyPriorityTables(sensors, constants);
    %end

end


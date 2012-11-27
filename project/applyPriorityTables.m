% Select load shedding and generator assignments based purely on priority tables
% This the crux of the LL-LMS system
function config = applyPriorityTables(sensors, constants)

    [BusGen1 BusGen2] = selectGenerators(sensors, constants);

    [Shedding1 Shedding2] = selectShedding(sensors, constants, BusGen1, BusGen2)

    config = []; %TODO
end

%note that 'constants' contains priorityTables
function [BusGen1 BusGen2] = selectGenerators(sensors, constants)
    %for now, just assume generators are all operational. Later, I'll come back and do it the right way.

    BusGen1 = [1 0 0]; %for now, just use gen 1 for bus 1 at all times
    BusGen2 = [0 1 0];
end

function [Shedding1 Shedding2] = selectShedding(sensors, constants, BusGen1, BusGen2) 
    Bus1_sum = sum(sensors.workload.Ls1) + sum(sensors.workload.Lns1)
    
    Shedding1 = [];

    Bus2_sum = sum(sensors.workload.Ls2) + sum(sensors.workload.Lns2)

    Shedding2 = [];
end


% Select load shedding and generator assignments based purely on priority tables
% This the crux of the LL-LMS system
function config = applyPriorityTables(sensors, constants)
    [BusGen] = selectGenerators(sensors, constants); %Del1,Del2 in Mehdi's code
    %[Shedding1 Shedding2] = selectShedding(sensors, constants, BusGen) %C1, C2 in Mehdi's code
    Shedding1 = ones([1 10]); Shedding2 = zeros([1 10]); %placeholder

    GeneratorOnOff = [1 1 0]; %TODO: assign this based on BusGen1 and BusGen2
    Battery1 = [0]; Battery2 = [0]; %Pwr used for charging each battery. Beta1, Beta2 in Mehdi's code

    config = struct('Shedding1', Shedding1, 'Shedding2', Shedding2, 'BusGen', BusGen, 'Battery1', Battery1, 'Battery2', Battery2, 'GeneratorOnOff', GeneratorOnOff); 
end


%note that 'constants' contains priorityTables
function [BusGen] = selectGenerators(sensors, constants)
    %for now, just assume generators are all operational. Later, I'll come back and do it the right way.

    BusGen = [1 2]; %for now, just use Gen1 for Bus1, and Gen2 for Bus2
    %BusGen1 = [1 0 0]; %for now, just use gen 1 for bus 1 at all times
    %BusGen2 = [0 1 0];
end

%FIXME: this doesn't promise to work properly yet
function [Shedding1 Shedding2] = selectShedding(sensors, constants, BusGen) 
    Bus1_pwrReq = sum(sensors.workload.Ls1) + sum(sensors.workload.Lns1)
    Bus2_pwrReq = sum(sensors.workload.Ls2) + sum(sensors.workload.Lns2)

    %TODO: decide how to use priority table and index it. (may want to tweak its implementation?)

    pwrReqGen1 = 0;
    pwrReqGen2 = 0;
    pwrReqApu = 0;

    if (BusGen(1) == 1)
        pwrReqGen1 = Bus1_pwrReq;
    end
    if (BusGen(1) == 2)
        pwrReqGen2 = Bus1_pwrReq;
    end
    if (BusGen(1) == 3)
        pwrReqApu = Bus1_pwrReq;
    end

    if (BusGen(2) == 1)
        pwrReqGen1 = pwrReqGen1 + Bus2_pwrReq;
    end
    if (BusGen(2) == 2)
        pwrReqGen2 = pwrReqGen2 + Bus2_pwrReq;
    end
    if (BusGen(2) == 3)
        pwrReqApu = pwrReqApu + Bus2_pwrReq;
    end

    Shedding1 = zeroes(1, 10);
    Shedding2 = zeroes(1, 10);
    priority = 10;
    while (pwrReqGen1 > constants.generatorOutput(1))
        if (BusGen(2) == 1) % remove sheddable load from right side first
            pwrReqGen1 = pwrReqGen1 - loadTbl2(priorty);
            Shedding2(priority) = 1;
        end
        if (BusGen(1) == 1 && pwrReqGen1 > constants.generatorOutput(1)) % now do it for the left side if still over
            pwrReqGen1 = pwrReqGen1 - loadTbl1(priority);
            Shedding1(priority) = 1;
        end
        priority = priority - 1;
    end

    priority = 10;
    while (pwrReqGen2 > constants.generatorOutput(2))
        if (BusGen(1) == 2) % remove sheddable load from left side first
            pwrReqGen2 = pwrReqGen2 - loadTbl1(priorty);
            Shedding1(priority) = 1;
        end
        if (BusGen(2) == 2 && pwrReqGen2 > constants.generatorOutput(2)) % now do it for the right side if still over
            pwrReqGen2= pwrReqGen2 - loadTbl2(priority);
            Shedding2(priority) = 1;
        end
        priority = priority - 1;
    end

    priority = 10;
    while (pwrReqApu > constants.generatorOutput(3))
        if (BusGen(1) == 3) % remove sheddable load from left side first
            pwrReqApu = pwrReqApu - loadTbl1(priorty);
            Shedding1(priority) = 1;
        end
        if (BusGen(2) == 3 && pwrReqGen2 > constants.generatorOutput(3)) % now do it for the right side if still over
            pwrReqApu = pwrReqApu - loadTbl2(priority);
            Shedding2(priority) = 1;
        end
        priority = priority - 1;
    end

end


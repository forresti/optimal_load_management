
function config = LLLMS(sensors, constants, advice)
    %if (checkSafety(advice, sensors, constants))
    %    config = advice;
    %else
        config = applyPriorityTables(sensors, constants);
    %end
end

% Select load shedding and generator assignments based purely on priority tables
% This the crux of the LL-LMS system
function config = applyPriorityTables(sensors, constants)
    [BusGen GeneratorOnOff] = selectGenerators(sensors, constants); %Del1,Del2 in Mehdi's code
    [Shedding1 Shedding2] = selectShedding(sensors, constants, BusGen); %C1, C2 in Mehdi's code

    Battery1 = [0]; Battery2 = [0]; %Pwr used for charging each battery. Beta1, Beta2 in Mehdi's code

    config = struct('Shedding1', Shedding1, 'Shedding2', Shedding2, 'BusGen', BusGen, 'Battery1', Battery1, 'Battery2', Battery2, 'GeneratorOnOff', GeneratorOnOff);
end

%note that 'constants' contains priorityTables
function [BusGen GeneratorOnOff] = selectGenerators(sensors, constants)
    %genPri1 = constants.priorityTables.genPri1; % [0 1 2] 
    %genPri2 = constants.priorityTables.genPri2;

    %HACK priority tables. Listing the generators in order of preference
    genPri1 = [1 3 2];
    genPri2 = [2 3 1]; % "first choice is Gen2, second choice is APU, third choice is Gen1"

    GeneratorOnOff = zeros([1 3]);
    BusGen = zeros([1 2]);

    %Bus 1 generator selection
    for i=1:constants.Ns %1 to number of generators
        if( sensors.genStatus(genPri1(i)) == 1) %this generator works properly
            BusGen(1) = genPri1(i);
            GeneratorOnOff(genPri1(i)) = 1; %turn the selected generator on
            break
        end
    end

    %Bus 2 generator selection
    for i=1:constants.Ns %1 to number of generators
        if(sensors.genStatus(genPri2(i)) == 1) %this generator works properly
            BusGen(2) = genPri2(i);
            GeneratorOnOff(genPri2(i)) = 1; %turn the selected generator on
            break
        end
    end
end

function [Shedding1 Shedding2] = selectShedding(sensors, constants, BusGen)
    Bus1_pwrReq = sum(sensors.workload.Ls1) + sum(sensors.workload.Lns1);
    Bus2_pwrReq = sum(sensors.workload.Ls2) + sum(sensors.workload.Lns2);

    pwrReqGen1 = 0; pwrReqGen2 = 0; pwrReqApu = 0;
    if (BusGen(1) == 1)
        pwrReqGen1 = Bus1_pwrReq;
    elseif (BusGen(1) == 2)
        pwrReqGen2 = Bus1_pwrReq;
    elseif (BusGen(1) == 3)
        pwrReqApu = Bus1_pwrReq;
    end

    if (BusGen(2) == 1)
        pwrReqGen1 = pwrReqGen1 + Bus2_pwrReq;
    elseif (BusGen(2) == 2)
        pwrReqGen2 = pwrReqGen2 + Bus2_pwrReq;
    elseif (BusGen(2) == 3)
        pwrReqApu = pwrReqApu + Bus2_pwrReq;
    end

    Shedding1 = ones(1, 10); %if Shedding(1)==1, then DON'T shed. if shedding(1)==0, then DO shed.
    Shedding2 = ones(1, 10);
    sheddingPri1 = constants.priorityTables.sheddingPri1;
    sheddingPri2 = constants.priorityTables.sheddingPri2;
    priority = 1;
    maxPriority = 10;
    while (pwrReqGen1 > constants.generatorOutput(1) && priority<=maxPriority)
        if (BusGen(2) == 1) % remove sheddable load from right side first
            pwrReqGen1 = pwrReqGen1 - sensors.workload.Ls2(sheddingPri2(1,priority));
            Shedding2(priority) = 0; %TODO: Shedding2(sheddingPri2(1,priority))
        elseif (BusGen(1) == 1 && pwrReqGen1 > constants.generatorOutput(1)) % now do it for the left side if still over
            pwrReqGen1 = pwrReqGen1 - sensors.workload.Ls1(sheddingPri1(1,priority));
            Shedding1(priority) = 0;
        end
        priority = priority + 1;
    end

    priority = 1;
    while (pwrReqGen2 > constants.generatorOutput(2) && priority<=maxPriority)
        if (BusGen(1) == 2) % remove sheddable load from left side first
            pwrReqGen2 = pwrReqGen2 - sensors.workload.Ls1(sheddingPri1(1,priority));
            Shedding1(priority) = 0;
        elseif (BusGen(2) == 2 && pwrReqGen2 > constants.generatorOutput(2)) % now do it for the right side if still over
            pwrReqGen2= pwrReqGen2 - sensors.workload.Ls2(sheddingPri2(1,priority));
            Shedding2(priority) = 0;
        end
        priority = priority + 1;
    end

    priority = 1;
    while (pwrReqApu > constants.generatorOutput(3) && priority<=maxPriority)
        if (BusGen(1) == 3) % remove sheddable load from left side first
            pwrReqApu = pwrReqApu - sensors.workload.Ls1(sheddingPri1(1,priority));
            Shedding1(priority) = 0;
        elseif (BusGen(2) == 3 && pwrReqGen2 > constants.generatorOutput(3)) % now do it for the right side if still over
            pwrReqApu = pwrReqApu - sensors.workload.Ls2(sheddingPri2(1,priority));
            Shedding2(priority) = 0;
        end
        priority = priority + 1;
    end
end




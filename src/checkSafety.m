
% Are any power caps exceeded?
function isSafe = checkSafety(config, sensors, constants)
    Shedding1 = config.Shedding1;
    Shedding2 = config.Shedding2;
    Bus1_pwrReq = sum(sensors.workload.Lns1) + sum(sensors.workload.Ls1(Shedding1>0)); %'Shedding1>0' is a Matlab 'logical coordinate'
    Bus2_pwrReq = sum(sensors.workload.Lns2) + sum(sensors.workload.Ls2(Shedding2>0));
   
    %calculate pwr required from each generator
    pwrReqGen1 = 0; pwrReqGen2 = 0; pwrReqApu = 0; 
    if (config.BusGen(1) == 1)
        pwrReqGen1 = Bus1_pwrReq - sensors.batteryCharge1;
    elseif (config.BusGen(1) == 2)
        pwrReqGen2 = Bus1_pwrReq - sensors.batteryCharge1;
    elseif (config.BusGen(1) == 3)
        pwrReqApu = Bus1_pwrReq - sensors.batteryCharge1;
    end

    if (config.BusGen(2) == 1)
        pwrReqGen1 = pwrReqGen1 + Bus2_pwrReq - sensors.batteryCharge2;
    elseif (config.BusGen(2) == 2)
        pwrReqGen2 = pwrReqGen2 + Bus2_pwrReq - sensors.batteryCharge2;
    elseif (config.BusGen(2) == 3)
        pwrReqApu = pwrReqApu + Bus2_pwrReq - sensors.batteryCharge2;
    end

    %decide whether any of the generators are being overdrawn
    isSafe=1;
    
    % check generator status
    if (sensors.genStatus(config.BusGen(1)) == 0 || sensors.genStatus(config.BusGen(2)) == 0) %have we assigned a broken generator to a bus?

        if(sensors.genStatus(config.BusGen(1)) == 0) %TEMPORARY for debugging
            display(sprintf('unsafe: HLLMS using a broken generator (Gen%d) at time %d', config.BusGen(1), sensors.time))
        else if(sensors.genStatus(config.BusGen(2)) == 0)
            display(sprintf('unsafe: HLLMS using a broken generator (Gen%d) at time %d', config.BusGen(2), sensors.time))
        end
        isSafe=0;
    end
 
    % checking for generator overload
    if(pwrReqGen1 > constants.generatorOutput(1))
        isSafe=0;
        display(sprintf('unsafe: Gen1 overloaded at time %d',sensors.time))
    elseif(pwrReqGen2 > constants.generatorOutput(2))
        isSafe=0;
        display(sprintf('unsafe: Gen2 overloaded at time %d',sensors.time))
    elseif(pwrReqApu > constants.generatorOutput(3))
        isSafe=0;
        display(sprintf('unsafe: APU overloaded at time %d',sensors.time))
    end
end



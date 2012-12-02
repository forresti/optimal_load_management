
% Are any power caps exceeded?
%function isSafe = checkSafety(config, sensors, constants)

%note: all 'binvar' objects are cast to double.
function isSafe = checkSafety(Shedding1, Shedding2, Ls1, Lns1, Ls2, Lns2, genAssignment1, genAssignment2, generatorOutput, time) 

    BusGen = [0 0];
    [myMax BusGen(1)] = max(genAssignment1);  %BusGen(1) is argmax here
    [myMax BusGen(2)] = max(genAssignment2);

    genStatus = [1 1 1]; %assume no generator failures for this experiment

    Bus1_pwrReq = sum(Ls1) + sum(Lns1(Shedding1>0)); %'Shedding1>0' is a Matlab 'logical coordinate
    Bus2_pwrReq = sum(Ls2) + sum(Lns2(Shedding2>0));
   
    %calculate pwr required from each generator
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

    %decide whether any of the generators are being overdrawn
    isSafe=1;
    
    % check generator status
    if (genStatus(BusGen(1)) == 0 || genStatus(BusGen(2)) == 0) %have we assigned a broken generator to a bus?
        isSafe=0;
    end
    
    % checking for generator overload
    if(pwrReqGen1 > generatorOutput(1))
        isSafe=0;
        sprintf('UNSAFE at time %d: Generator 1 produces %d power units, but the HL-LMS allocated Generator 1 to provide %d power units', time, generatorOutput(1), pwrReqGen1)
    elseif(pwrReqGen2 > generatorOutput(2))
        isSafe=0;
        sprintf('UNSAFE at time %d: Generator 2 produces %d power units, but the HL-LMS allocated Generator 2 to provide %d power units', time, generatorOutput(2), pwrReqGen2)
    elseif(pwrReqApu > generatorOutput(3))
        sprintf('UNSAFE at time %d: APU produces %d power units, but the HL-LMS allocated APU to provide %d power units', time, generatorOutput(3), pwrReqApu)
        isSafe=0;
    end
end



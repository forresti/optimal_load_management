%This is the "main function" for our airplane power simulation system

%@param useHL -- decide whether to do HL+LL or just LL system
function [] = runAirplane(useHL)
    close all hidden %get rid of old figures

    nTimesteps=100; % total number of timesteps in runAirplane outer loop 
    Nl=10;   % number of loads connected to each bus. (10 sheddable, 10 unsheddable)
    Ns=3;    % number of power sources
    Nb=2;    % number of buses

    %N and Nt are params for HL-LMS
    HLclockMultiplier=10; % (HLclock rate) = HLclockMultiplier * (LLclock rate)
    N = HLclockMultiplier; % prediction horizon
    %N = 3*HLclockMultiplier; % prediction horizon
    Nt = N+1; % (prediction horizon + 1) -- some off-by-one-fix relic.
    minBatteryLevel = 50000; %afterthe tMinBatteryLevel-th timestep
    maxBatteryLevel =- 5e6;
    %tMinBatteryLevel = 10; %first timestep to take minBatteryLevel into account
    tMinBatteryLevel = 0;

    sensorLog = [];
    configLog = [];
    %generatorOutput = [1e5, 1e5, 104e3]; %Pwr produced by generators. Called U1, U2, U3 in Mehdi's code
    generatorOutput = [1e5, 1e5, 1e5];
    [Ls1,Lns1,Ls2,Lns2]=load3(110);
    historicalWorkloads = struct('Ls1', Ls1, 'Lns1', Lns1, 'Ls2', Ls2, 'Lns2', Lns2);
    priorityTables = getPriorityTables();
    constants = struct('historicalWorkloads', historicalWorkloads, 'priorityTables', priorityTables, 'generatorOutput', generatorOutput, 'nTimesteps', nTimesteps, 'Nt', Nt, 'Nl', Nl, 'Ns', Ns, 'Nb', Nb, 'N', N, 'minBatteryLevel', minBatteryLevel, 'maxBatteryLevel', maxBatteryLevel, 'tMinBatteryLevel', tMinBatteryLevel); %hard-coded params to pass around  
    
    %batteryCharge1=0; batteryCharge2=0; %keep track of battery charge level
    batteryCharge1=100000; batteryCharge2=100000;
    advice = [];
    nextAdvice = [];
    HLclock = 1; %count up to each time we call the HLLMS
    
    for LLclock=1:nTimesteps
        workload = genWorkload(historicalWorkloads, LLclock, 0);
        genStatus = getGeneratorStatus(LLclock);
        sensors = struct('workload', workload, 'genStatus', genStatus, 'time', LLclock, 'batteryCharge1', batteryCharge1, 'batteryCharge2', batteryCharge2);

        %if (HLclock == 1 && LLclock <= (nTimesteps-N) && useHL == true) %time to call HLLMS again
        if (HLclock == 1 && useHL == true)
            %resize the horizon if we're getting near the end of the simulation
            constants.N = min(LLclock+constants.N, nTimesteps+1) - LLclock;  %avoid out-of-bounds horizon
            constants.Nt = constants.N+1; %horizon+1
            %nextWorkload = genWorkload(historicalWorkloads, LLclock+N, 0);
            %nextSensors = sensors;
            %nextSensors.workload = nextWorkload;
            %nextSensors.time = LLclock + N; %optimize for next horizon
            %nextSensors.batteryCharge1 = batteryCharge1; %will be 0 if the first advice hasn't been produced yet, otherwise, see the ~isempty(advice) below.
            %nextSensors.batteryCharge2 = batteryCharge2;

            %if (~isempty(advice))
            %    for adviceIdx=1:N 
            %        nextSensors.batteryCharge1 = nextSensors.batteryCharge1 + advice(adviceIdx).batteryUpdate1;
            %        nextSensors.batteryCharge2 = nextSensors.batteryCharge2 + advice(adviceIdx).batteryUpdate2;
            %    end
            %end
            %nextAdvice = HLLMS(nextSensors, constants);
            advice = HLLMS(sensors, constants);
        end

        if (~isempty(advice))
            config = LLLMS(sensors, constants, advice(HLclock));
            if(config.HLadviceUsed)
                batteryCharge1 = batteryCharge1 + config.batteryUpdate1; 
                batteryCharge2 = batteryCharge2 + config.batteryUpdate2;            
            end
        else config = LLLMS(sensors, constants, []);
        end
            
        if (HLclock == HLclockMultiplier) HLclock = 1; 
        else HLclock = HLclock + 1; 
        end

        display(sprintf('Bus 1 uses generator %d, Bus 2 uses generator %d at time %d', config.BusGen(1), config.BusGen(2), LLclock))

        %using sensors(i).batteryCharge = batteryCharge for *beginning* of the timestep. this way, we capture the starting battery condition. plotGraphs indexes the batteryCharge graph from zero.
        %sensors.batteryCharge1=batteryCharge1; sensors.batteryCharge2=batteryCharge2; %batteries may have changed since beginning of the timestep. other 'stuff that changed during the timestep' is stored in config.
        configLog = [configLog config]; %this concatenation is slow ... but that's fine. 
        sensorLog = [sensorLog sensors];
    end
    plotGraphs(configLog, sensorLog, constants, Nt, nTimesteps)
end




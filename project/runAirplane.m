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
    Nt = N+1; % (prediction horizon + 1) -- some off-by-one-fix relic.

    sensorLog = [];
    configLog = [];
    generatorOutput = [1e5, 1e5, 104e3]; %Pwr produced by generators. Called U1, U2, U3 in Mehdi's code
    [Ls1,Lns1,Ls2,Lns2]=load3(110);
    historicalWorkloads = struct('Ls1', Ls1, 'Lns1', Lns1, 'Ls2', Ls2, 'Lns2', Lns2);
    priorityTables = getPriorityTables();
    constants = struct('historicalWorkloads', historicalWorkloads, 'priorityTables', priorityTables, 'generatorOutput', generatorOutput, 'nTimesteps', nTimesteps, 'Nt', Nt, 'Nl', Nl, 'Ns', Ns, 'Nb', Nb, 'N', N); %hard-coded params to pass around  
    
    batteryCharge1=0; batteryCharge2=0; %keep track of battery charge level
    advice = [];
    nextAdvice = [];
    HLclock = 1; %count up to each time we call the HLLMS
    
    for LLclock=1:nTimesteps
        workload = genWorkload(historicalWorkloads, LLclock, 0);
        genStatus = getGeneratorStatus(LLclock);
        sensors = struct('workload', workload, 'genStatus', genStatus, 'time', LLclock, 'batteryCharge1', batteryCharge1, 'batteryCharge2', batteryCharge2);

        if (HLclock == 1 && LLclock <= (nTimesteps-N) && useHL == true) %time to call HLLMS again
            advice = nextAdvice;
            nextWorkload = genWorkload(historicalWorkloads, LLclock+N, 0);
            nextSensors = sensors;
            nextSensors.workload = nextWorkload;
            nextSensors.time = LLclock + N; %optimize for next horizon
            nextSensors.batteryCharge1 = batteryCharge1; %will be 0 if the first advice hasn't been produced yet, otherwise, see the ~isempty(advice) below.
            nextSensors.batteryCharge2 = batteryCharge2;

            if (~isempty(advice))
                for adviceIdx=1:N 
                    nextSensors.batteryCharge1 = nextSensors.batteryCharge1 + advice(adviceIdx).batteryUpdate1;
                    nextSensors.batteryCharge2 = nextSensors.batteryCharge2 + advice(adviceIdx).batteryUpdate2;
                end
            end
            nextAdvice = HLLMS(nextSensors, constants);
        end

        if (~isempty(advice))
            config = LLLMS(sensors, constants, advice(HLclock));
            %TODO: add a way to check if LLLMS actually used the HLLMS advice.
            %batteryCharge1 = batteryCharge1 + config.batteryUpdate1; %TODO: only do this if LLLMS takes the advice.
            %batteryCharge2 = batteryCharge2 + config.batteryUpdate2;            
        else config = LLLMS(sensors, constants, []);
        end
            
        if (HLclock == HLclockMultiplier) HLclock = 1; 
        else HLclock = HLclock + 1; 
        end

        configLog = [configLog config]; %this concatenation is slow ... but that's fine. 
        sensorLog = [sensorLog sensors];
    end
    plotGraphs(configLog, sensorLog, constants, Nt, nTimesteps)
end




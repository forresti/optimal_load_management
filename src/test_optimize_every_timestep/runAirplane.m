%This is the "main function" for our airplane power simulation system
function [] = runAirplane()
    close all hidden %get rid of old figures

    nTimesteps=100; % total number of timesteps in runAirplane outer loop 
    Nl=10;   % number of loads connected to each bus. (10 sheddable, 10 unsheddable)
    Ns=3;    % number of power sources
    Nb=2;    % number of buses

    %N and Nt are params for for Mehdi's code
    N = 2; % prediction horizon
    Nt = 2+1; % (prediction horizon + 1) -- some off-by-one-fix relic.

    sensorLog = [];
    configLog = [];
    generatorOutput = [1e5, 1e5, 104e3]; %Pwr produced by generators. Called U1, U2, U3 in Mehdi's code
        %TODO: make generatorOutput be a parameter to Mehdi's code, so that we can tweak it easily.
    %[Ls1,Lns1,Ls2,Lns2]=load3(typecast(nTimesteps+Nt, 'int32')); % load the "loads" -- choose between load1, load2 and load3. (including extra padding, Nt, to avoid out-of-bounds in HLLMS)
    [Ls1,Lns1,Ls2,Lns2]=load4(110);
    historicalWorkloads = struct('Ls1', Ls1, 'Lns1', Lns1, 'Ls2', Ls2, 'Lns2', Lns2);
    priorityTables = getPriorityTables();
    constants = struct('historicalWorkloads', historicalWorkloads, 'priorityTables', priorityTables, 'generatorOutput', generatorOutput, 'nTimesteps', nTimesteps, 'Nt', Nt, 'Nl', Nl, 'Ns', Ns, 'Nb', Nb, 'N', N); %hard-coded params to pass around  
    
    advice = [];
    HLclock = 1; %count up to each time we call the HLLMS
    for time=1:nTimesteps
        workload = genWorkload(historicalWorkloads, time);
        genStatus = getGeneratorStatus(time);
        sensors = struct('workload', workload, 'genStatus', genStatus, 'time', time);

        advice = HLLMS(sensors, constants);
        config = LLLMS(sensors, constants, advice(HLclock));

        configLog = [configLog config]; %this concatenation is slow ... but that's fine. 
        sensorLog = [sensorLog sensors];
    end
    plotGraphs(configLog, sensorLog, constants, Nt, nTimesteps)
end




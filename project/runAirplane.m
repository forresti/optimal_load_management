
%This is the "main function" for our airplane power simulation system
function [] = runAirplane()

    N = 100+10; %number of timesteps
    horizon = 10;
    Nl=10;   % number of loads connected to each bus. (10 sheddable, 10 unsheddable)
    Ns=3;    % number of power sources
    Nb=2;    % number of buses

    generatorOutput = [1e5, 1e5, 104e3]; %Pwr produced by generators. Called U1, U2, U3 in Mehdi's code
        %TODO: make generatorOutput be a parameter to Mehdi's code, so that we can tweak it easily.
    [Ls1,Lns1,Ls2,Lns2]=load3(N); % load the "loads" -- choose between load1, load2 and load3.
    historicalWorkloads = struct('Ls1', Ls1, 'Lns1', Lns1, 'Ls2', Ls2, 'Lns2', Lns2);
    priorityTables = getPriorityTables();
    constants = struct('historicalWorkloads', historicalWorkloads, 'priorityTables', priorityTables, 'generatorOutput', generatorOutput, 'horizon', horizon, 'Nl', Nl, 'Ns', Ns, 'Nb', Nb); %hard-coded params to pass around  
 

    for time=1:N
    %for time=1:2 %test
        workload = genWorkload(historicalWorkloads, time);
        genStatus = getGeneratorStatus(time);
        sensors = struct('workload', workload, 'genStatus', genStatus, 'time', time)

        %config = applyPriorityTables(sensors, constants)
        config = LL_LMS(sensors, constants)
    end

end



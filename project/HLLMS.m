function [configs] = HLLMS(sensors, constants) %only using 'sensors' for generator status
    N = constants.N; % number of timesteps (use all timesteps -- no interpolation or kron)
    Nt = constants.Nt; % prediction horizon
    Nl = constants.Nl; % number of loads connected to each bus
    Ns = constants.Ns; % number of power sources
    Nb = constants.Nb; % number of HVAC buses

    %% load the "loads"
    [Ls1 Lns1 Ls2 Lns2] = sliceWorkloads(sensors, constants); %get relevant slice of historicalWorkloads
  
    %% Max. Power supply by Engines and APU
    U1=constants.generatorOutput(1);     Peng1=U1*ones(1,Nt);
    U2=constants.generatorOutput(2);     Peng2=U2*ones(1,Nt);
    U3=constants.generatorOutput(3);   Papu=U3*ones(1,Nt);
    U=[U1*ones(1,Nt); U2*ones(1,Nt); U3*ones(1,Nt)];
    P=[Peng1' Peng2' Papu'];
    startBatteryCharge1=sensors.batteryCharge1; startBatteryCharge2=sensors.batteryCharge2;

    %% Optimization problem set-up
    tic;
    %Coefficients (one set for Bus 1, one set for Bus 2):
    Lambda1=[0 1 2];                    Lambda2=[1 0 2]; %generator priority table (GR, GL, APU)
    %Lambda1=[0 2 0];                    Lambda2=[1 2 0]; %pri table: prefer APU over other side's generator 
    Gamma1=1000*ones(1,Nl);             Gamma2=500*ones(1,Nl); %load shedding priority table (one value for each load at each timestep)
   % M=10; %'mu' -- weight for alpha (see eq.9 in OLMS paper)
    M=100;

    % Decision variables (one set for Bus 1, one set for Bus 2)
    C1=binvar(Nl,Nt,'full');            C2=binvar(Nl,Nt,'full'); %C1(l,t) = "shed load l at time t?:
    Del1=binvar(Ns,Nt,'full');          Del2=binvar(Ns,Nt,'full'); %Del1(g,t) = "is bus 1 powered by generator g at time t?"
    Beta1=sdpvar(1,Nt,'full');          Beta2=sdpvar(1,Nt,'full'); %Beta1(1,t) = "amount of pwr used for battery 1 at time t"
    Y1=sdpvar(Ns,Nt,'full');            Y2=sdpvar(Ns,Nt,'full'); %what is this?
    alpha=binvar(Nt,Ns,'full'); %alpha(t,g) = "is anything drawing pwr from generator g at time t?"
    Pito1=sdpvar(Nt,Ns,'full');         Pito2=sdpvar(Nt,Ns,'full'); %Pito1(t,g) = "amount of pwr delivered by generator g to bus 1 at time t"
    BETA1 = sdpvar(1,Nt,'full'); BETA2 = sdpvar(1,Nt,'full'); %cumulative battery charge. (lowercase Beta is per-timestep change in charge)
    nSwitch1 = sdpvar(1,Nt,'full'); nSwitch2 = sdpvar(1,Nt,'full'); nSwitch3 = sdpvar(1,Nt,'full'); nSwitch4 = sdpvar(1,Nt,'full'); nSwitch5 = sdpvar(1,Nt,'full'); nSwitch6 = sdpvar(1,Nt,'full');

    % Constraints
    cons=[];
    cons=[cons, 0 <= BETA1, 0 <= BETA2];
    %cons=[cons, 0 <= BETA1 <= constants.maxBatteryLevel, 0 <= BETA2 <= constants.maxBatteryLevel]; %battery charge level can't be negative 
    for i=1:Nl-1
        cons=[cons, C1(i,:) <= C1(i+1,:), C2(i,:) <= C2(i+1,:)];
    end
    cons=[ cons, sum(Del1,1) == ones(1,Nt)];  % \delta_11(t) + \delta12(t) + \delta_13(t)=1    \forall t>=0
    cons=[ cons, sum(Del2,1) == ones(1,Nt)];
    for i=1:Ns %hard code "generator broken" where necessary
        if (sensors.genStatus(i) == 0)
            cons=[cons, alpha(:,i)==0]; %require that generator i is off
            cons=[cons, Del1(i,:)==0, Del2(i,:)==0]; %require that nobody draws power from gen i
        end
    end

    x=1:1:N;
    xi=0:N/(Nt-1):N; xi(1)=1;  % 0:10:100

    % the following five lead to MILP.
    cons=[cons, sum(C1.*interp1(x,Ls1',xi)',1) + sum(interp1(x,Lns1',xi),2)' == sum(Y1,1) - Beta1];   %\sum cji(t)*lji(t)= \sum \deta_ji *P_source_i - Betaj
    cons=[cons, sum(C2.*interp1(x,Ls2',xi)',1) + sum(interp1(x,Lns2',xi),2)' == sum(Y2,1) - Beta2];
    cons=[cons, Y1' + Y2' == alpha.*P];    % The three constraints of the form \delta_{11}*P_{1to1} + \delta_{2to1}*P_{2to2}=P_{eng1}
    cons=[cons,  0 <= Y1 <= Pito1', 0 <= Y2 <= Pito2'];
    cons=[cons, Pito1' - U.*(1-Del1) <= Y1 <= U.*Del1, Pito2' - U.*(1-Del2) <= Y2 <= U.*Del2];

    if(sensors.time >= constants.tMinBatteryLevel)
        cons=[cons, constants.minBatteryLevel <= BETA1, constants.minBatteryLevel <= BETA2];
        display(sprintf('using minBatteryLevel starting at time %d', sensors.time)) 
    elseif((constants.tMinBatteryLevel - sensors.time) < 0) %TODO: check correctness
        display('not using minBatteryLevel constraint')
        my_tMinBatteryLevel = constants.tMinBatteryLevel - sensors.time;
        cons=[cons, maxBatteryLevel <= BETA1(my_tMinBatteryLevel:Nt) >= minBatteryLevel, BETA2(my_tMinBatteryLevel:Nt) >= minBatteryLevel]; %enforce lower bound on battery charge level after the tMinBatteryLevel-th timestep
    end 

    %everything is shifted to start at 2 (see 'configs' below), so Beta1(1),Beta2(1) is (ignored?)
    BETA1(1) = startBatteryCharge1; BETA2(1) = startBatteryCharge2;     
    for i=2:Nt
        cons=[cons, BETA1(i) == BETA1(i-1) + Beta1(i), BETA2(i) == BETA2(i-1) + Beta2(i)];
    end

    nSwitch1=0; nSwitch2=0; nSwitch3=0; nSwitch4=0; nSwitch5=0; nSwitch6=0;
    for i=1:Nt-1
        nSwitch1=nSwitch1 + abs( Del1(1,i)-Del1(1,i+1) );
        nSwitch2=nSwitch2 + abs( Del1(2,i)-Del1(2,i+1) );
        nSwitch3=nSwitch3 + abs( Del1(3,i)-Del1(3,i+1) );
        
        nSwitch4=nSwitch4 + abs( Del2(1,i)-Del2(1,i+1) );
        nSwitch5=nSwitch5 + abs( Del2(2,i)-Del2(2,i+1) );
        nSwitch6=nSwitch6 + abs( Del2(3,i)-Del2(3,i+1) );
    end 
    NOAS=3;  % Number Of Allowed Switchings
    cons=[cons, nSwitch1<=NOAS, nSwitch2<=NOAS, nSwitch3<=NOAS];
    cons=[cons, nSwitch4<=NOAS, nSwitch5<=NOAS, nSwitch6<=NOAS];

    % Objective
    obj=0;
    obj = obj + sum(Gamma1 * (1-C1)) + sum (Gamma2 * (1-C2));
    obj = obj + sum(Lambda1 * Del1) + sum(Lambda2 * Del2);
    obj = obj + M * sum(sum(alpha));

    options=sdpsettings('solver','Cplex'); %windows needs 'Cplex' and mac is ok with 'cplex' or 'Cplex'
    solvesdp(cons,obj,options);
    toc;

    Shedding1 = double(C1(:,:));
    Shedding2 = double(C2(:,:));
    batteryUpdate1 = double(Beta1(:,:));
    batteryUpdate2 = double(Beta2(:,:)); 
    Del1_double = double(Del1(:,:));
    Del2_double = double(Del2(:,:));
    GeneratorOnOff = double(alpha(:,:)); % unlike the other variables, alpha's time index comes first

    configs = []; %array of 'config' data structures
    for i=1:(Nt-1) %1 to horizon
        BusGen = [0 0];
        [myMax BusGen(1)] = max(Del1_double(:,i+1));  %BusGen(1) is argmax here
        [myMax BusGen(2)] = max(Del2_double(:,i+1));

        config = struct('Shedding1', Shedding1(:,i+1)', 'Shedding2', Shedding2(:,i+1)', 'BusGen', BusGen, 'batteryUpdate1', batteryUpdate1(:,i+1), 'batteryUpdate2', batteryUpdate2(:,i+1), 'GeneratorOnOff', GeneratorOnOff(i,:), 'HLadviceUsed', true);
        configs = [configs config];
    end
end

function [Ls1 Lns1 Ls2 Lns2] = sliceWorkloads(sensors, constants)
    nTimestepsOuterLoop = max(size(constants.historicalWorkloads.Ls1(1,:)));
    lo = sensors.time;
    hi = min((sensors.time + constants.N)-1, nTimestepsOuterLoop); %out-of-bounds check
    Ls1 = constants.historicalWorkloads.Ls1(:, lo:hi);
    Lns1 = constants.historicalWorkloads.Lns1(:, lo:hi);
    Ls2 = constants.historicalWorkloads.Ls2(:, lo:hi);
    Lns2 = constants.historicalWorkloads.Lns2(:, lo:hi);
end


function [config] = HLLMS(sensors, constants) %only using 'sensors' for generator status
    % Choose between different load files, load1, load2, load3,...

    %% constants
    %Nt=10+1;   % length of prediction horizon (I think)   % can select: 10+1, 20+1, 50+1 and 100+1.
    %Nl=10;   % number of loads connected to each bus
    %Ns=3;    % number of power sources
    %Nb=2;    % number of HVAC buses
    %N=100;   % number of timesteps

    %Nt = constants.Nt; % length of prediction horizon (I think)
    Nt = 1; %test
    Nl = constants.Nl; % number of loads connected to each bus
    Ns = constants.Ns; % number of power sources
    Nb = constants.Nb; % number of HVAC buses
    %N = constants.N; % number of timesteps
    N = 1; %test
    startTime = sensors.time;

    %% load the "loads"
    %[Ls1,Lns1,Ls2,Lns2]=load3(N);   % choose between load1, load2 and load3.
    Ls1 = constants.historicalWorkload.Ls1;
    Lns1 = constants.historicalWorkload.Lns1;
    Ls2 = constants.historicalWorkload.Ls2;
    Lns2 = constants.historicalWorkload.Lns2;
  
    %% Max. Power supply by Engines and APU
    U1=1e5;     Peng1=U1*ones(1,Nt);
    U2=1e5;     Peng2=U2*ones(1,Nt);
    U3=104e3;   Papu=U3*ones(1,Nt);
    U=[U1*ones(1,Nt); U2*ones(1,Nt); U3*ones(1,Nt)];
    P=[Peng1' Peng2' Papu'];

    %% Optimization problem set-up
    tic;
    %Coefficients (one set for Bus 1, one set for Bus 2):
    Lambda1=[0 1 2];                    Lambda2=[1 0 2]; %generator priority table (GR, GL, APU)
    Gamma1=1000*ones(1,Nl);             Gamma2=500*ones(1,Nl); %load shedding priority table (one value for each load at each timestep)
    M=10; %'mu' -- weight for alpha (see eq.9 in OLMS paper)

    % Decision variables (one set for Bus 1, one set for Bus 2)
    C1=binvar(Nl,Nt,'full');            C2=binvar(Nl,Nt,'full'); %C1(l,t) = "shed load l at time t?:
    Del1=binvar(Ns,Nt,'full');          Del2=binvar(Ns,Nt,'full'); %Del1(g,t) = "is bus 1 powered by generator g at time t?"
    Beta1=sdpvar(1,Nt,'full');          Beta2=sdpvar(1,Nt,'full'); %Beta1(1,t) = "amount of pwr used for battery 1 at time t"
    Y1=sdpvar(Ns,Nt,'full');            Y2=sdpvar(Ns,Nt,'full'); %what is this?
    alpha=binvar(Nt,Ns,'full'); %alpha(t,g) = "is anything drawing pwr from generator g at time t?"

    Pito1=sdpvar(Nt,Ns,'full');         Pito2=sdpvar(Nt,Ns,'full'); %Pito1(t,g) = "amount of pwr delivered by generator g to bus 1 at time t"

    % Constraints
    cons=[];
    cons=[cons, Beta1 >= 0; Beta2 >= 0];
    for i=1:Nl-1
        cons=[cons, C1(i,:) <= C1(i+1,:), C2(i,:) <= C2(i+1,:)];
    end
    cons=[ cons, sum(Del1,1) == ones(1,Nt)];  % \delta_11(t) + \delta12(t) + \delta_13(t)=1    \forall t>=0
    cons=[ cons, sum(Del2,1) == ones(1,Nt)];
    for i=1:Ns %hard code "generator broken" where necessary
        if (sensors.genStatus(i) == 0)
            cons = [cons, alpha(:, i)=0]; %require that generator i is not used
        end
    end

    x=1:1:100;
    xi=0:N/(Nt-1):N; xi(1)=1;  % 0:10:100

    % the following five lead to MILP.
    cons=[ cons, sum(C1.*interp1(x,Ls1',xi)',1) + sum(interp1(x,Lns1',xi),2)' == sum(Y1,1) - Beta1];   %\sum cji(t)*lji(t)= \sum \deta_ji *P_source_i - Betaj
    cons=[ cons, sum(C2.*interp1(x,Ls2',xi)',1) + sum(interp1(x,Lns2',xi),2)' == sum(Y2,1) - Beta2];
    cons=[ cons, Y1' + Y2' == alpha.*P];    % The three constraints of the form \delta_{11}*P_{1to1} + \delta_{2to1}*P_{2to2}=P_{eng1}
    cons=[ cons,  0 <= Y1 <= Pito1', 0 <= Y2 <= Pito2'];
    cons=[ cons, Pito1' - U.*(1-Del1) <= Y1 <= U.*Del1, Pito2' - U.*(1-Del2) <= Y2 <= U.*Del2];

    % Objective
    obj=0;
    obj = obj + sum(Gamma1 * (1-C1)) + sum (Gamma2 * (1-C2));
    obj = obj + sum(Lambda1 * Del1) + sum(Lambda2 * Del2);
    obj = obj + M * sum(sum(alpha));

    options=sdpsettings('solver','Cplex'); %windows needs 'Cplex' and mac is ok with 'cplex' or 'Cplex'
    solvesdp(cons,obj,options);
    toc;

    %test2 = kron(double(C1(1,:)),ones(1,100/(Nt-1))) %this is how to get an actual matrix from C1(1,:)

    %TODO: pack the results into a 'config' data structure.

    Shedding1 = kron(double(C1(:,startTime)),ones(1,100/(Nt-1)));
    Shedding2 = kron(double(C2(:,startTime)),ones(1,100/(Nt-1)));
    Battery1 = kron(double(Beta1(:,startTime)),ones(1,100/(Nt-1)));
    Battery2 = kron(double(Beta2(:,startTime)),ones(1,100/(Nt-1)));
        

    BusGen = [0 0];
    [myMax BusGen(1)] = max(Del1(:,startTime))  %BusGen(1) is argmax here
    [myMax BusGen(2)] = max(Del2(:,startTime))

    %TODO: work out whether to make this for "one timestep" or "whole horizon"
    %config = struct('Shedding1', C1, 'Shedding2', C2, 'BusGen', BusGen, 'Battery1', Beta1, 'Battery2', Beta2, 'GeneratorOnOff', alpha)
    config = []

end



function [] = OptProb_Linear_Function()
    % Choose between different load files, load1, load2, load3,...

    clear all
    %% constants
    Nt=10+1;   % number of time steps   % can select: 10+1, 20+1, 50+1 and 100+1.
    Nl=10;   % number of loads connected to each bus
    Ns=3;    % number of power sources
    Nb=2;    % number of HVAC buses

    N=100;   % length of prediction horizon

    %% load the "loads"
    [Ls1,Lns1,Ls2,Lns2]=load3(N);   % choose between load1, load2 and load3.

    %% Plot the load requirements 

    %Load requirements for bus 1
    Ls1sum=sum(Ls1,1); 
    Lns1sum=sum(Lns1,1);

    figure;
    subplot(2,1,1);
    plot(1:1:N,Lns1sum,'--b','LineWidth',2);
    title('P_{req}(t) for bus 1');
    xlabel('time [s]');
    ylabel('P_{req_1} [W]');
    grid on;
    L1sum=Ls1sum+Lns1sum;
    hold on;
    plot(1:1:N,L1sum,'-r','LineWidth',2);
    legend('L_{ns}','L_{s}+L_{ns}');
    axis([1 N 0 1.1*max(L1sum)]);


    % Load requirements for bus 2
    Ls2sum=sum(Ls2,1); 
    Lns2sum=sum(Lns2,1); 

    %figure;
    subplot(2,1,2);
    plot(1:1:N,Lns2sum,'--b','LineWidth',2);
    title('P_{req}(t) for bus 2');
    xlabel('time [s]');
    ylabel('P_{req_2} [W]');
    grid on;
    L2sum=Ls2sum+Lns2sum;
    hold on;
    plot(1:1:N,L2sum,'-r','LineWidth',2);
    legend('L_{ns}','L_{s}+L_{ns}');
    axis([1 N 0 1.1*max(L2sum)]);

    %% Max. Power supply by Engines and APU

    U1=1e5;     Peng1=U1*ones(1,Nt);
    U2=1e5;     Peng2=U2*ones(1,Nt);
    U3=104e3;   Papu=U3*ones(1,Nt);
    U=[U1*ones(1,Nt); U2*ones(1,Nt); U3*ones(1,Nt)];
    P=[Peng1' Peng2' Papu'];

    %% Optimization problem set-up
    tic;
    %Coefficients:
    Lambda1=[0 1 2];                    Lambda2=[1 0 2];
    Gamma1=1000*ones(1,Nl);             Gamma2=500*ones(1,Nl); 
    M=10;

    % Decision variables
    C1=binvar(Nl,Nt,'full');            C2=binvar(Nl,Nt,'full');
    Del1=binvar(Ns,Nt,'full');          Del2=binvar(Ns,Nt,'full');
    Beta1=sdpvar(1,Nt,'full');          Beta2=sdpvar(1,Nt,'full');
    Y1=sdpvar(Ns,Nt,'full');            Y2=sdpvar(Ns,Nt,'full');
    alpha=binvar(Nt,Ns,'full');

    Pito1=sdpvar(Nt,Ns,'full');         Pito2=sdpvar(Nt,Ns,'full');   

    % Constraints
    cons=[];
    cons=[cons, Beta1 >= 0; Beta2 >= 0];
    for i=1:Nl-1
        cons=[cons, C1(i,:) <= C1(i+1,:), C2(i,:) <= C2(i+1,:)];
    end


    cons=[ cons, sum(Del1,1) == ones(1,Nt)];  % \delta_11(t) + \delta12(t) + \delta_13(t)=1    \forall t>=0
    cons=[ cons, sum(Del2,1) == ones(1,Nt)];

    x=1:1:100;
    xi=0:N/(Nt-1):N; xi(1)=1;  % 0:10:100

    % the following three lead to MINLP.
    % cons=[ cons, sum(C1.*interp1(x,Ls1',xi)',1) + sum(interp1(x,Lns1',xi),2)' == diag(Pito1*Del1)' - Beta1];   %\sum cji(t)*lji(t)= \sum \deta_ji *P_source_i - Betaj
    % cons=[ cons, sum(C2.*interp1(x,Ls2',xi)',1) + sum(interp1(x,Lns2',xi),2)' == diag(Pito2*Del2)' - Beta2];
    % cons=[ cons, Pito1 .* Del1' + Pito2 .* Del2' == alpha.*P];    % The three constraints of the form \delta_{11}*P_{1to1} + \delta_{2to1}*P_{2to2}=P_{eng1}

    % the following five lead to MILP.
    cons=[ cons, sum(C1.*interp1(x,Ls1',xi)',1) + sum(interp1(x,Lns1',xi),2)' == sum(Y1,1) - Beta1];   %\sum cji(t)*lji(t)= \sum \deta_ji *P_source_i - Betaj
    cons=[ cons, sum(C2.*interp1(x,Ls2',xi)',1) + sum(interp1(x,Lns2',xi),2)' == sum(Y2,1) - Beta2];
    cons=[ cons, Y1' + Y2' == alpha.*P];    % The three constraints of the form \delta_{11}*P_{1to1} + \delta_{2to1}*P_{2to2}=P_{eng1}
    cons=[ cons,  0 <= Y1 <= Pito1', 0 <= Y2 <= Pito2'];
    cons=[ cons, Pito1' - U.*(1-Del1) <= Y1 <= U.*Del1, Pito2' - U.*(1-Del2) <= Y2 <= U.*Del2];
    %cons=[cons, sum(alpha,2) <= Nb*ones(Nt,1)];
    %cons = [cons, Del1' + Del2' ==alpha];  % WRONG!

    % Objective
    obj=0;
    obj = obj + sum(Gamma1 * (1-C1)) + sum (Gamma2 * (1-C2));
    obj = obj + sum(Lambda1 * Del1) + sum(Lambda2 * Del2);
    obj = obj + M * sum(sum(alpha));

    options=sdpsettings('solver','Cplex'); %windows needs 'Cplex' and mac is ok with 'cplex' or 'Cplex'
    solvesdp(cons,obj,options);
    toc;

    % Plot C
    xp=1:1:Nt*100/(Nt-1);  % 110
    figure;
    subplot(2,2,1);
    plot(xp,kron(double(C1(1,:)),ones(1,100/(Nt-1))),xp,kron(double(C1(2,:)),ones(1,100/(Nt-1))),xp,kron(double(C1(3,:)),ones(1,100/(Nt-1))),...
        xp,kron(double(C1(4,:)),ones(1,100/(Nt-1))),xp,kron(double(C1(5,:)),ones(1,100/(Nt-1))),'LineWidth',2);
    legend('L_1','L_2','L_3','L_4','L_5','Orientation','horizontal');
    title('Power shedding of AC bus 1 (loads 1 to 5)');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Shed (off)','Granted (on)'});
    xlabel('time [s]');

    subplot(2,2,2);
    plot(xp,kron(double(C2(1,:)),ones(1,100/(Nt-1))),xp,kron(double(C2(2,:)),ones(1,100/(Nt-1))),xp,kron(double(C2(3,:)),ones(1,100/(Nt-1))),...
        xp,kron(double(C2(4,:)),ones(1,100/(Nt-1))),xp,kron(double(C2(5,:)),ones(1,100/(Nt-1))),'LineWidth',2);
    legend('L_1','L_2','L_3','L_4','L_5','Orientation','horizontal');
    title('Power shedding of AC bus 2 (loads 1 to 5)');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Shed (off)','Granted (on)'});
    xlabel('time [s]');

    subplot(2,2,3);
    plot(xp,kron(double(C1(6,:)),ones(1,100/(Nt-1))),xp,kron(double(C1(7,:)),ones(1,100/(Nt-1))),xp,kron(double(C1(8,:)),ones(1,100/(Nt-1))),...
        xp,kron(double(C1(9,:)),ones(1,100/(Nt-1))),xp,kron(double(C1(10,:)),ones(1,100/(Nt-1))),'LineWidth',2);
    legend('L_6','L_7','L_8','L_9','L_{10}','Orientation','horizontal');
    title('Power shedding of AC bus 1 (loads 6 to 10)');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Shed (off)','Granted (on)'});
    xlabel('time [s]');

    subplot(2,2,4);
    plot(xp,kron(double(C2(6,:)),ones(1,100/(Nt-1))),xp,kron(double(C2(7,:)),ones(1,100/(Nt-1))),xp,kron(double(C2(8,:)),ones(1,100/(Nt-1))),...
        xp,kron(double(C2(9,:)),ones(1,100/(Nt-1))),xp,kron(double(C2(10,:)),ones(1,100/(Nt-1))),'LineWidth',2);
    legend('L_6','L_7','L_8','L_9','L_{10}','Orientation','horizontal');
    title('Power shedding of AC bus 2 (loads 6 to 10)');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Shed (off)','Granted (on)'});
    xlabel('time [s]');

    % Plot Delta
    figure;
    subplot(2,1,1);
    % plot(xi,double(Del1(1,:)),xi,double(Del1(2,:)),xi,double(Del1(3,:)));
    plot(xp,kron(double(Del1(1,:)),ones(1,100/(Nt-1))),xp,kron(double(Del1(2,:)),ones(1,100/(Nt-1))),xp,kron(double(Del1(3,:)),ones(1,100/(Nt-1))),'LineWidth',2);
    legend('GEN 1','GEN 2','APU','Orientation','horizontal');
    title('AC bus 1 power suppliers - - \Delta_1 (t)');
    axis([0 N+10 -0.1 1.5]);
    xlabel('time [s]');

    subplot(2,1,2);
    % plot(xi,double(Del2(1,:)),xi,double(Del2(2,:)),xi,double(Del2(3,:)));
    plot(xp,kron(double(Del2(1,:)),ones(1,100/(Nt-1))),xp,kron(double(Del2(2,:)),ones(1,100/(Nt-1))),xp,kron(double(Del2(3,:)),ones(1,100/(Nt-1))),'LineWidth',2);
    legend('GEN 1','GEN 2','APU','Orientation','horizontal');
    title('AC bus 2 power suppliers - - \Delta_2 (t)');
    axis([0 N+10 -0.1 1.5]);
    xlabel('time [s]');

    % Plot Beta
    figure;
    subplot(2,1,1);
    %plot(xp,sign(kron(double(Beta1),ones(1,10))),'b','LineWidth',2);
    plot(xp,(kron(double(Beta1),ones(1,100/(Nt-1))))>=0.1,'b','LineWidth',2);  % sign results into error if the value is e.g. -1.2*1e-10! Therefore we use this.
    title('Battery charging status for DC bus 1');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Not-charging','Charging'});
    xlabel('time [s]');

    subplot(2,1,2);
    %plot(xp,sign(kron(double(Beta2),ones(1,10))),'b','LineWidth',2);
    plot(xp,(kron(double(Beta2),ones(1,100/(Nt-1))))>=0.1,'b','LineWidth',2);  % sign results into error if the value is e.g. -1.2*1e-10! Therefore we use this.
    title('Battery charging status for DC bus 2');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Not-charging','Charging'});
    xlabel('time [s]');

    % figure;
    % plot(double(Beta2))
end

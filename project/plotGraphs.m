
% Expects ordinary arrays, not binvar arrays. (so, we got rid of '' and stuff)
function plotGraphs(configLog, sensorLog, constants, Nt, N)

    xp=1:1:Nt*100/(Nt-1);  % 110
    plotPowerReq(constants.historicalWorkloads.Ls1, constants.historicalWorkloads.Lns1, constants.historicalWorkloads.Ls2, constants.historicalWorkloads.Lns2, N)
    plotC(configLog(:).Shedding1, configLog(:).Shedding2, Nt, N, xp)

    %TODO convert our config.BusGen into Del1,Del2. 
    %plotDelta(Del1, Del2, Nt, N, xp)

    %plotBeta(Beta1, Beta2, Nt, N, xp)
end

function plotPowerReq(Ls1, Lns1, Ls2, Lns2, N)
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
end

%plot load shedding
function plotC(C1, C2, Nt, N, xp)
    % Plot C
    xp=1:1:Nt*100/(Nt-1);  % 110
    figure;
    subplot(2,2,1);
    %plot(xp,(double(C1(1,:)),ones(1,100/(Nt-1))),xp,(double(C1(2,:)),ones(1,100/(Nt-1))),xp,(double(C1(3,:)),ones(1,100/(Nt-1))),...
    %    xp,(double(C1(4,:)),ones(1,100/(Nt-1))),xp,(double(C1(5,:)),ones(1,100/(Nt-1))),'LineWidth',2);
    plot(C1(1,:),C1(2,:),C1(3,:),C1(4,:),C1(5,:))

    legend('L_1','L_2','L_3','L_4','L_5','Orientation','horizontal');
    title('Power shedding of AC bus 1 (loads 1 to 5)');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Shed (off)','Granted (on)'});
    xlabel('time [s]');

    subplot(2,2,2);
    %plot(xp,(double(C2(1,:)),ones(1,100/(Nt-1))),xp,(double(C2(2,:)),ones(1,100/(Nt-1))),xp,(double(C2(3,:)),ones(1,100/(Nt-1))),...
    %    xp,(double(C2(4,:)),ones(1,100/(Nt-1))),xp,(double(C2(5,:)),ones(1,100/(Nt-1))),'LineWidth',2);
    plot(C2(1,:),C2(2,:),C2(3,:),C2(4,:),C2(5,:))
    legend('L_1','L_2','L_3','L_4','L_5','Orientation','horizontal');
    title('Power shedding of AC bus 2 (loads 1 to 5)');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Shed (off)','Granted (on)'});
    xlabel('time [s]');

    subplot(2,2,3);
    %plot(xp,(double(C1(6,:)),ones(1,100/(Nt-1))),xp,(double(C1(7,:)),ones(1,100/(Nt-1))),xp,(double(C1(8,:)),ones(1,100/(Nt-1))),...
    %    xp,(double(C1(9,:)),ones(1,100/(Nt-1))),xp,(double(C1(10,:)),ones(1,100/(Nt-1))),'LineWidth',2);
    plot(C1(6,:),C1(7,:),C1(8,:),C1(9,:),C1(10,:))
    legend('L_6','L_7','L_8','L_9','L_{10}','Orientation','horizontal');
    title('Power shedding of AC bus 1 (loads 6 to 10)');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Shed (off)','Granted (on)'});
    xlabel('time [s]');

    subplot(2,2,4);
    %plot(xp,(double(C2(6,:)),ones(1,100/(Nt-1))),xp,(double(C2(7,:)),ones(1,100/(Nt-1))),xp,(double(C2(8,:)),ones(1,100/(Nt-1))),...
    %    xp,(double(C2(9,:)),ones(1,100/(Nt-1))),xp,(double(C2(10,:)),ones(1,100/(Nt-1))),'LineWidth',2);
    plot(C2(6,:),C2(7,:),C2(8,:),C2(9,:),C2(10,:))
    legend('L_6','L_7','L_8','L_9','L_{10}','Orientation','horizontal');
    title('Power shedding of AC bus 2 (loads 6 to 10)');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Shed (off)','Granted (on)'});
    xlabel('time [s]');
end

function plotDelta(Del1, Del2, Nt, N, xp)
    % Plot Delta
    figure;
    subplot(2,1,1);
    plot(xi,double(Del1(1,:)),xi,double(Del1(2,:)),xi,double(Del1(3,:)));
    %plot(xp,(double(Del1(1,:)),ones(1,100/(Nt-1))),xp,(double(Del1(2,:)),ones(1,100/(Nt-1))),xp,(double(Del1(3,:)),ones(1,100/(Nt-1))),'LineWidth',2);
    legend('GEN 1','GEN 2','APU','Orientation','horizontal');
    title('AC bus 1 power suppliers - - \Delta_1 (t)');
    axis([0 N+10 -0.1 1.5]);
    xlabel('time [s]');

    subplot(2,1,2);
    plot(xi,double(Del2(1,:)),xi,double(Del2(2,:)),xi,double(Del2(3,:)));
    %plot(xp,(double(Del2(1,:)),ones(1,100/(Nt-1))),xp,(double(Del2(2,:)),ones(1,100/(Nt-1))),xp,(double(Del2(3,:)),ones(1,100/(Nt-1))),'LineWidth',2);
    legend('GEN 1','GEN 2','APU','Orientation','horizontal');
    title('AC bus 2 power suppliers - - \Delta_2 (t)');
    axis([0 N+10 -0.1 1.5]);
    xlabel('time [s]');
end

function plotBeta(Beta1, Beta2, Nt, N, xp)
    figure;
    subplot(2,1,1);
    %plot(xp,sign((double(Beta1),ones(1,10))),'b','LineWidth',2);
    plot(Beta1>=0.1,'b','LineWidth',2);  % sign results into error if the value is e.g. -1.2*1e-10! Therefore we use this.
    title('Battery charging status for DC bus 1');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Not-charging','Charging'});
    xlabel('time [s]');

    subplot(2,1,2);
    %plot(xp,sign((double(Beta2),ones(1,10))),'b','LineWidth',2);
    plot(Beta2>=0.1,'b','LineWidth',2);  % sign results into error if the value is e.g. -1.2*1e-10! Therefore we use this.
    title('Battery charging status for DC bus 2');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Not-charging','Charging'});
    xlabel('time [s]');
end


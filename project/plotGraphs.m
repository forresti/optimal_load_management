% Expects ordinary arrays, not binvar arrays. (so, we got rid of '' and stuff)
function plotGraphs(configLog, sensorLog, constants, Nt, N)

    xp=1:1:Nt*100/(Nt-1);  % 110
    plotPowerReq(constants.historicalWorkloads.Ls1(:,1:N), constants.historicalWorkloads.Lns1(:,1:N), constants.historicalWorkloads.Ls2(:,1:N), constants.historicalWorkloads.Lns2(:,1:N), N)

    %Shedding1 = configLog(:).Shedding1; doesn't work -- it just returns the first timestep instead of all timesteps
    Shedding1 = []; Shedding2 = [];
    for i=1:N
        Shedding1 = [Shedding1; configLog(i).Shedding1];
        Shedding2 = [Shedding2; configLog(i).Shedding2];
    end
    plotLoadShedding(Shedding1', Shedding2', Nt, N, xp)

    batteryUpdate1 = []; batteryUpdate2 = []; %Beta1, Beta2
    batteryCharge1 = []; batteryCharge2 = []; %BETA1, BETA2
    for i=1:N
        batteryUpdate1 = [batteryUpdate1; configLog(i).batteryUpdate1]; batteryUpdate2 = [batteryUpdate2; configLog(i).batteryUpdate2];
        batteryCharge1 = [batteryCharge1; sensorLog(i).batteryCharge1]; batteryCharge2 = [batteryCharge2; sensorLog(i).batteryCharge2];
    end
  
    size(configLog) 
    dBatteryUpdate1 = [configLog.batteryUpdate1] %easier way to pull an element out of all indices in array of structs
    configLog
 
    plotBatteryBinary(batteryUpdate1, batteryUpdate2, Nt, N, xp)
    plotBatteryUpdate(batteryUpdate1, batteryUpdate2, Nt, N, xp)
    plotBatteryStorage(batteryCharge1, batteryCharge2, Nt, N, xp, constants.minBatteryLevel)

    BusGen = [];  %generator selection
    for i=1:N
        BusGen = [BusGen; configLog(i).BusGen];
    end
    plotGenSelection(BusGen, Nt, N, xp) 
    
    HLadviceUsed = [];
    for i=1:N
        HLadviceUsed = [HLadviceUsed; configLog(i).HLadviceUsed];
    end
    plotHLadviceUsed(HLadviceUsed, Nt, N, xp)
end

function plotPowerReq(Ls1, Lns1, Ls2, Lns2, N)
    %Load requirements for bus 1
    Ls1sum=sum(Ls1,1); 
    Lns1sum=sum(Lns1,1);

    h=figure;
    subplot(2,1,1);
    plot(1:1:N,Lns1sum,'--b','LineWidth',2);
    title('P_{req}(t) for bus 1', 'fontsize',10,'fontweight','b');
    xlabel('time [s]', 'fontsize',10,'fontweight','b');
    ylabel('P_{req_1} [W]', 'fontsize',10,'fontweight','b');
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
    title('P_{req}(t) for bus 2', 'fontsize',10,'fontweight','b');
    xlabel('time [s]', 'fontsize',10,'fontweight','b');
    ylabel('P_{req_2} [W]', 'fontsize',10,'fontweight','b');
    grid on;
    L2sum=Ls2sum+Lns2sum;
    hold on;
    plot(1:1:N,L2sum,'-r','LineWidth',2);
    legend('L_{ns}','L_{s}+L_{ns}');
    axis([1 N 0 1.1*max(L2sum)]);

    print(h, '-depsc2', 'figures/powerReq.eps');
    print(h, '-dpng', 'figures/powerReq.png');
end

%plot load shedding
function plotLoadShedding(C1, C2, Nt, N, xp)
    xp=1:N;

    %TODO: two legends stacked vertically. see Richie Cotton's post here: http://stackoverflow.com/questions/5674426/how-can-i-customize-the-positions-of-legend-elements

    left=0; bottom=0; width=1000; height=500;
    h=figure('Position',[left, bottom, width, height]); %set size
    subplot(2,2,1);
    %plot(xp,C1(1,:),xp,C1(2,:)+0.02,xp,C1(3,:)+0.04,xp,C1(4,:)+0.06,xp,C1(5,:)+0.08,xp,C1(6,:)+0.10,xp,C1(7,:)+0.12,xp,C1(8,:)+0.14,xp,C1(9,:)+0.16,xp,C1(10,:)+0.18, 'LineWidth',1.5)
    %legend('L_1','L_2','L_3','L_4', ['L_5' char(10) 'line'], 'L_6', 'L_7', 'L_8', 'L_9', 'L_{10}','Orientation','horizontal');
    %title('Power shedding of AC bus 1 (loads 1 to 10)');
    plot(xp,C1(1,:),xp,C1(2,:)+0.02,xp,C1(3,:)+0.04,xp,C1(4,:)+0.06,xp,C1(5,:)+0.08, 'LineWidth',1.5)
    legend('L_1','L_2','L_3','L_4','L_5','Orientation','horizontal');
    title('Power shedding of AC bus 1 (loads 1 to 5)', 'fontsize',10,'fontweight','b');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Shed (off)','Granted (on)'}, 'fontsize',10,'fontweight','b');
    xlabel('time [s]', 'fontsize',10,'fontweight','b');

    subplot(2,2,2);
    plot(xp,C2(1,:),xp,C2(2,:)+0.02,xp,C2(3,:)+0.04,xp,C2(4,:)+0.06,xp,C2(5,:)+0.08, 'LineWidth',1.5)
    legend('L_1','L_2','L_3','L_4','L_5','Orientation','horizontal');
    title('Power shedding of AC bus 2 (loads 1 to 5)', 'fontsize',10,'fontweight','b');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Shed (off)','Granted (on)'}, 'fontsize',10,'fontweight','b');
    xlabel('time [s]', 'fontsize',10,'fontweight','b');

    subplot(2,2,3);
    plot(xp,C1(6,:),xp,C1(7,:)+0.02,xp,C1(8,:)+0.04,xp,C1(9,:)+0.06,xp,C1(10,:)+0.08, 'LineWidth',1.5)
    legend('L_6','L_7','L_8','L_9','L_{10}','Orientation','horizontal');
    title('Power shedding of AC bus 1 (loads 6 to 10)', 'fontsize',10,'fontweight','b');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Shed (off)','Granted (on)'},'fontsize',10,'fontweight','b');
    xlabel('time [s]', 'fontsize',10,'fontweight','b');

    subplot(2,2,4);
    plot(xp,C2(6,:),xp,C2(7,:)+0.02,xp,C2(8,:)+0.04,xp,C2(9,:)+0.06,xp,C2(10,:)+0.08, 'LineWidth',1.5)
    legend('L_6','L_7','L_8','L_9','L_{10}','Orientation','horizontal');
    title('Power shedding of AC bus 2 (loads 6 to 10)', 'fontsize',10,'fontweight','b');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Shed (off)','Granted (on)'}, 'fontsize',10,'fontweight','b');
    xlabel('time [s]', 'fontsize',10,'fontweight','b');
    print(h, '-depsc2', 'figures/loadShedding.eps');
    print(h, '-dpng', 'figures/loadShedding.png');
end

function plotGenSelection(BusGen, Nt, N, xp)
    Del1(1,:) = (BusGen(:,1)==1)';
    Del1(2,:) = (BusGen(:,1)==2)';
    Del1(3,:) = (BusGen(:,1)==3)';
    Del2(1,:) = (BusGen(:,2)==1)';
    Del2(2,:) = (BusGen(:,2)==2)';
    Del2(3,:) = (BusGen(:,2)==3)';
    xp = xp(1:size(Del1(1,:)')); %trim xp if necessary

    h=figure;
    subplot(2,1,1);
    plot(xp,Del1(1,:), xp,Del1(2,:)+0.02, xp,Del1(3,:)+0.04, 'LineWidth',2.5);
    legend('GEN 1','GEN 2','APU','Orientation','horizontal');
    title('AC bus 1 power suppliers -- \Delta_1 (t)', 'fontsize',10,'fontweight','b');
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Disconnected', 'Connected'}, 'fontsize',10,'fontweight','b');
    axis([0 N+10 -0.1 1.5]);
    xlabel('time [s]', 'fontsize',10,'fontweight','b');

    subplot(2,1,2);
    plot(xp,Del2(1,:), xp,Del2(2,:)+0.02, xp,Del2(3,:)+0.04, 'LineWidth',2.5);
    legend('GEN 1','GEN 2','APU','Orientation','horizontal');
    title('AC bus 2 power suppliers -- \Delta_2 (t)', 'fontsize',10,'fontweight','b');
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Disconnected', 'Connected'}, 'fontsize',10,'fontweight','b');
    axis([0 N+10 -0.1 1.5]);
    xlabel('time [s]', 'fontsize',10,'fontweight','b');

    print(h, '-depsc2', 'figures/genSelection.eps');
    print(h, '-dpng', 'figures/genSelection.png');
end

function plotBatteryBinary(Beta1, Beta2, Nt, N, xp)
    figure;
    subplot(2,1,1);
    plot(Beta1>=0.1,'b','LineWidth',2);  % sign results into error if the value is e.g. -1.2*1e-10! Therefore we use this.
    title('Battery charging status for DC bus 1', 'fontsize',10,'fontweight','b');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Not-charging','Charging'}, 'fontsize',10,'fontweight','b');
    xlabel('time [s]', 'fontsize',10,'fontweight','b');

    subplot(2,1,2);
    plot(Beta2>=0.1,'b','LineWidth',2);  % sign results into error if the value is e.g. -1.2*1e-10! Therefore we use this.
    title('Battery charging status for DC bus 2', 'fontsize',10,'fontweight','b');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'Not-charging','Charging'}, 'fontsize',10,'fontweight','b');
    xlabel('time [s]', 'fontsize',10,'fontweight','b');
end

function plotBatteryUpdate(Beta1, Beta2, Nt, N, xp)
    h=figure;
    subplot(2,1,1);
    plot(Beta1,'b','LineWidth',2);  % sign results into error if the value is e.g. -1.2*1e-10! Therefore we use this.
    title('Battery charging for DC bus 1', 'fontsize',10,'fontweight','b');
    axis([0 N+10 -100000 100000]);
    ylabel('Battery Charging per timestep','fontsize',10,'fontweight','b')
    xlabel('time [s]', 'fontsize',10,'fontweight','b');

    subplot(2,1,2);
    plot(Beta2,'b','LineWidth',2);  % sign results into error if the value is e.g. -1.2*1e-10! Therefore we use this.
    title('Battery charging for DC bus 2', 'fontsize',10,'fontweight','b');
    axis([0 N+10 -100000 100000]);
    ylabel('Battery Charging per timestep', 'fontsize',10,'fontweight','b')
    xlabel('time [s]', 'fontsize',10,'fontweight','b');
    print(h, '-depsc2', 'figures/batteryUpdate.eps');
    print(h, '-dpng', 'figures/batteryUpdate.png');
end

function plotBatteryStorage(BETA1, BETA2, Nt, N, xp, minBatteryLevel)
    h=figure;
    subplot(2,1,1);    
    %plot(cumsum(Beta1),'b','LineWidth',2);  % sign results into error if the value is e.g. -1.2*1e-10! Therefore we use this.
    plot(BETA1,'b','LineWidth',2);
    hold on;
    plot(1:1:N, minBatteryLevel,'--b','LineWidth',2);
    title('Battery charge level for DC bus 1', 'fontsize',10,'fontweight','b');
    axis([0 N+10 0 500000]);
    ylabel('Battery Charge Level per timestep', 'fontsize',10,'fontweight','b')
    xlabel('time [s]', 'fontsize',10,'fontweight','b');

    subplot(2,1,2);    
    plot(BETA2,'b','LineWidth',2);  % sign results into error if the value is e.g. -1.2*1e-10! Therefore we use this.    
    hold on;
    plot(1:1:N, minBatteryLevel,'--b','LineWidth',2);
    title('Battery charge level for DC bus 2', 'fontsize',10,'fontweight','b');
    axis([0 N+10 0 500000]);
    ylabel('Battery Charge Level per timestep', 'fontsize',10,'fontweight','b')
    xlabel('time [s]', 'fontsize',10,'fontweight','b');
    print(h, '-depsc2', 'figures/batteryStorage.eps')
    print(h, '-dpng', 'figures/batteryStorage.png');
end

function plotHLadviceUsed(HLadviceUsed, Nt, N, xp)
    h=figure;
    plot(HLadviceUsed,'b','LineWidth',2);  % sign results into error if the value is e.g. -1.2*1e-10! Therefore we use this.
    title('Hierarchical control status', 'fontsize',10,'fontweight','b');
    axis([0 N+10 -0.1 1.5]);
    set(gca,'YTick',0:1:1);
    set(gca,'YTickLabel',{'LL-LMS', 'HL-LMS'}, 'fontsize',10,'fontweight','b');
    xlabel('time [s]', 'fontsize',10,'fontweight','b');
    print(h, '-depsc2', 'figures/HLadviceUsed.eps')
    print(h, '-dpng', 'figures/HLadviceUsed.png');
end


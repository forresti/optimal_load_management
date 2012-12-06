% Get a workload at a particular time.
% One way to do this is to just use (and perhaps slightly perturb) historical workloads
function workload = genWorkload(historicalWorkloads, time, doPerturb)
    Ls1 = historicalWorkloads.Ls1(:,time);
    Lns1 = historicalWorkloads.Lns1(:,time);
    Ls2 = historicalWorkloads.Ls2(:,time);
    Lns2 = historicalWorkloads.Lns2(:,time);
    newLs1 = perturbBus(Ls1);
    newLns1 = perturbBus(Lns1);
    newLs2 = perturbBus(Ls2);
    newLns2 = perturbBus(Lns2);
    if (doPerturb)
      workload = struct('Ls1', newLs1, 'Lns1', newLns1, 'Ls2', newLs2, 'Lns2', newLns2);
    else
       workload = struct('Ls1', Ls1, 'Lns1', Lns1, 'Ls2', Ls2, 'Lns2', Lns2);
    end
        
end

%perturb one set of workloads on a bus (e.g. Ls1, Lns1, ...)
function bus =  perturbBus(bus)
    randRange = 4.0; %will use random numbers in the space (-randRange/2, randRange/2)
    Nl = size(bus); %number of individual loads to perturb
    perturbation = (rand(Nl) * (randRange)) - (randRange/2); %random vector of size Nl with the specified range, centered at 0
    bus = abs(bus + bus .* perturbation);

end


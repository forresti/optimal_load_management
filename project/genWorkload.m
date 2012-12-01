% Get a workload at a particular time.
% One way to do this is to just use (and perhaps slightly perturb) historical workloads
function workload = genWorkload(historicalWorkloads, time)
    %TODO: add perurbations to the workloads

    randRange = 0.6; %random numbers in the space (-randRange/2, randRange/2)
    Nl = size(historicalWorkloads.Ls1(:,time)); %assume all sets of workloads (Ls1, Lns1, ...) are of same size

    %newLs1 = historicalWorkloads.Ls1(:,time);
    %newLns1 = historicalWorkloads.Lns1(:,time);
    %newLs2 = historicalWorkloads.Ls2(:,time);
    %newLns2 = historicalWorkloads.Lns2(:,time);

    newLs1 = perturbBus(historicalWorkloads.Ls1(:,time));
    newLns1 = perturbBus(historicalWorkloads.Lns1(:,time));
    newLs2 = perturbBus(historicalWorkloads.Ls2(:,time));
    newLns2 = perturbBus(historicalWorkloads.Lns2(:,time));
    workload = struct('Ls1', newLs1, 'Lns1', newLns1, 'Ls2', newLs2, 'Lns2', newLns2)
end

%perturb one set of workloads on a bus (e.g. Ls1, Lns1, ...)
function bus =  perturbBus(bus)
    randRange = 0.6; %random numbers in the space (-randRange/2, randRange/2)
    Nl = size(bus) %number of individual loads to perturb
    perturbation = (rand(Nl) * (randRange)) - (randRange/2); %random vector of size Nl with the specified range, centered at 0
    bus = bus + bus .* perturbation;

end


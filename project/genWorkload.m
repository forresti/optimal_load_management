% Get a workload at a particular time.
% One way to do this is to just use (and perhaps slightly perturb) historical workloads
function workload = genWorkload(historicalWorkloads, time)
    %TODO: add perurbations to the workloads

    newLs1 = historicalWorkloads.Ls1(:,time);
    newLns1 = historicalWorkloads.Lns1(:,time);
    newLs2 = historicalWorkloads.Ls2(:,time);
    newLns2 = historicalWorkloads.Lns2(:,time);
    workload = struct('Ls1', newLs1, 'Lns1', newLns1, 'Ls2', newLs2, 'Lns2', newLns2);
end




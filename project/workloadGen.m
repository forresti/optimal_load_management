% Get a workload at a particular time.
% One way to do this is to just use (and perhaps slightly perturb) historical workloads
function workload = workloadGen(historicalWorkloads, time)
    %TODO: add perurbations to the workloads

    newLs1 = historicalWorkloads.Ls1(:,time);
    newLns1 = historicalWorkloads.Lns1(:,time);
    newLs2 = historicalWorkloads.Ls2(:,time);
    newLns2 = historicalWorkloads.Lns2(:,time);
    workload = struct('newLs1', newLs1, 'newLns1', newLns1, 'newLs2', newLs2, 'newLns2', newLns2);
end




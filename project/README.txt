To run our project, type the following into matlab

  runAirplane

Make sure to either be in the project directory or add our project directory to your path. 
By default, runAirplan uses load1.m as the load characterization. It assumes no generator failures and that
the actual workloads match the historical workloads.

General
Running this Matlab script produces two sets of graphs: a graph of power requests on the bus and a graph of load
shedding.
To change workload data, go to line 19 in runAirplan.m and change the load to load2, load3, or load4. Default is
load1.m

Generator Failures
To introduce generator failures, modify getGeneratorStatus.m. The function takes an input time and returns a 3 element
binary vector representing the generator's status at that moment in time. The format is as follows: 
  [LeftGenerator RightGenerator APU]. 
A 1 indicates healthy while a 0 indicates failure. 

Changes in load
The changes to run this experiment is done in runAirplane.m. On line 28 change

  workloadExperiment = 0

to

  workloadExperiment = 1

Currently, we only have one file to simulate actual workloads, called load1Mod.m. You can certainly swap out a different
file to simulate actual workloads. To do this, modify line 20 to use the load that you want. Default is load1Mod.m.
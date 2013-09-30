To run our project, type the following into matlab

``` Matlab
  runAirplane(1) %use hierarchical controller 
  runAirplane(0) %use simple low-level controller
  runAirplane %default to hierarchical controller
```

Make sure to either be in the project directory or add our project directory to your path. 
By default, runAirplan uses load1.m as the load characterization. It assumes no generator failures and that
the actual workloads match the historical workloads.


Graphs
By default, runAirplane.m uses plotGraphs.m to produce several graphs, which summarize workloads, power provided by each generator/APU, and battery usage.

Workloads
To change workload data, use load1, load2, load3, or load4 near the beginning of runAirplane.m. 

Generator Failures
To introduce generator failures, modify getGeneratorStatus.m. 
The function takes an input time and returns a 3 element binary vector representing the generator's status at that moment in time. The format is as follows: 
  [LeftGenerator RightGenerator APU]. 
A 1 indicates healthy while a 0 indicates failure. 


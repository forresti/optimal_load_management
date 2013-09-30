
<h5>This aircraft EPS controller implementation accompanies the following paper:</h5>

```
Mehdi Maasoumy, Pierluigi Nuzzo, Forrest Iandola, Maryam Kamgarpour, Alberto Sangiovanni-Vincentelli and Claire Tomlin.
"Optimal Load Management System for Aircraft Electric Power Distribution."
IEEE Conference on Decision and Control (CDC), 2013.
```

<h3>Getting Started</h3>
To run an aircraft power simulation using our controller, experiment with the following on the Matlab prompt:

``` Matlab
  runAirplane(1) %use hierarchical controller 
  runAirplane(0) %use simple low-level controller
  runAirplane %default to hierarchical controller
```

<h3>Setup</h3>
...install cplex and yalmip... (TODO: give a list of dependencies)

<h3>Graphs</h3>
By default, runAirplane.m uses plotGraphs.m to produce several graphs, which summarize workloads, power provided by each generator/APU, and battery usage.

<h3>Aircraft Power Workloads</h3>
To change workload data, use load1, load2, load3, or load4 near the beginning of runAirplane.m. 
Ideally, these workloads are similar to what you'd find in a commercial aircraft. 
As you can see, the workload varies throughout the flight -- avionics systems, cabin lights, and coffee makers may or may not be at their peak power draw at any given time in the flight.

<h3>Generator Failures</h3>
To introduce generator failures, modify getGeneratorStatus.m. 
The function takes an input time and returns a 3 element binary vector representing the generator's status at that moment in time. The format is as follows: 
  [LeftGenerator RightGenerator APU]. 
A 1 indicates healthy while a 0 indicates failure. 


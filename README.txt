To run our project,

1) Open up Matlab

2) Set the search path to this folder.
   Important, otherwise Matlab won't include
   our libraries.

3) Open Lab2_AircraftEPS
   -- This is necessary because we're using the
      Simulink model to visualize everything

See (4a) for automatic tests.
See (4b) to make manual tests.

4a) Run tests by invoking the Matlab test scripts
    -- run allfail.m // all 4 generators will crash, one after another
    -- run glfail.m  // only the left generator fails
    Then hit run in the simulink model.

4b) Run tests by manually changing the Step blocks controlling the
    generator status. According to the lab, these blocks must 
    start out at 1 and then (if desired) go to 0. These blocks
    should never go from 0 to 1. This behavior is undefined
    since the lab guaranteed that this scenario should never happen.
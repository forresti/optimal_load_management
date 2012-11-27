% Initialize the 'config' structure, and insert some harmless data
% Note that 'config' is for ONE timestep
function config = getInitialConfig(constants)
    %constants might be used for Nb, Ns, Nl

    Nl = 10;
    Shedding1 = ones([1 Nl]); %C1 in Mehdi's code. Binary vector for shedding in Bus 1. Shed nothing for the moment.
    Shedding2 = ones([1 Nl]); %C2 in Mehdi's code

    BusGen1 = [1 0 0]; %Del1 in Mehdi's code. Use Gen1 for Bus1
    BusGen2 = [0 1 0]; %Del1 in Mehdi's code. Use Gen2 for Bus2
    
    Battery1 = [0]; Battery2 = [0]; %Pwr used for charging each battery. Beta1, Beta2 in Mehdi's code
    GeneratorOnOff = [1 1 0]; %alpha in Mehdi's code. Run Gen1 and Gen2. Turn off APU

    config = struct('Shedding1', Shedding1, 'Shedding2', Shedding2, 'BusGen1', BusGen1, 'BusGen2', BusGen2, 'Battery1', Battery1, 'Battery2', Battery2, 'GeneratorOnOff', GeneratorOnOff)
end 



% Initialize the 'config' structure, and insert some harmless data
% Note that 'config' is for ONE timestep
function config = getInitialConfig(constants)
    %constants might be used for Nb, Ns, Nl
    Nl = 10;
    Shedding1 = ones([1 Nl]); %C1 in Mehdi's code. Binary vector for shedding in Bus 1. Shed nothing for the moment.
    Shedding2 = ones([1 Nl]); %C2 in Mehdi's code
    BusGen = [1 2]; %BusGen(1)=1, so Bus1 uses Gen1. BusGen(2)=2, so Bus2 uses Gen2.
    Battery1 = [0]; Battery2 = [0]; %Pwr used for charging each battery. Beta1, Beta2 in Mehdi's code
    GeneratorOnOff = [1 1 0]; %alpha in Mehdi's code. Run Gen1 and Gen2. Turn off APU

    config = struct('Shedding1', Shedding1, 'Shedding2', Shedding2, 'BusGen', BusGen, 'Battery1', Battery1, 'Battery2', Battery2, 'GeneratorOnOff', GeneratorOnOff)
end 



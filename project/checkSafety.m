
% Are any power caps exceeded?
function isSafe = checkSafety(config, sensors, constants)
    
    %TODO: figure out pwrReqGen1, pwrReqGen2, pwrReqGen3

    %pwrReqGen1 = sum...  ...need to figure out which bus uses which generator
    %pwrReqGen2 = ...
    %pwrReqGen3 = ...

    isSafe=1;
    if(pwrReqGen1 > constants.generatorOutput(1))
        isSafe=0;
    elseif(pwrReqGen2 > constants.generatorOutput(2))
        isSafe=0;
    elseif(pwrReqGen3 > constants.generatorOutput(3))
        isSafe=0;
    end
end



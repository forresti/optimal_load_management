% 'global selection' -- each case statement selects a full system configuration
% @param generatorHealth = binary vector for [GL AL AR GR]
% @output contactors = binary vector to enable/disable contactors [B1 ... B12]
function [contactors] = BPCU(generatorHealth)
    GL = generatorHealth(1);
    AL = generatorHealth(2);
    AR = generatorHealth(3);
    GR = generatorHealth(4);

    contactors = zeros([1 12]) %test

    if 1 && ~0
        x = 'blah'
    

end


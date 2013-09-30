
% 'global selection' -- each case statement selects a full system configuration
% @param generatorHealth = binary vector for [GL AL AR GR];
% @output contactors = binary vector to enable/disable contactors [B1 ... B12];
function [contactors] = BPCU_core(generatorHealth)
    GL = generatorHealth(1);
    AL = generatorHealth(2);
    AR = generatorHealth(3);
    GR = generatorHealth(4);

    if GL && GR
        contactors = [1 0 0 1 0 0]; %GL power left, GR power right
    elseif ~GL && GR
        if AL
            contactors = [0 1 0 1 1 0]; %GL off, GR power right, AL power left 
        elseif AR
            contactors = [0 0 1 1 1 0]; %GL off, GR power right, AR power left
        else
            contactors = [0 0 0 1 1 1]; %GR power whole plane, everything else off
        end
    elseif GL && ~GR
        if AR
            contactors = [1 0 1 0 0 1]; %GR off, GL power left, AR power right
        elseif AL
            contactors = [1 1 0 0 0 1]; %GR off, GL power left, AL power right
        else
            contactors = [1 0 0 0 1 1]; %GL power whole plane, everything else off
        end
    elseif ~GL && ~GR
        %it's arbitrary whether to use AL or AR in this case
        if AR
            contactors = [0 0 1 0 1 1]; %GL off, GR off, AR power whole plane
        elseif AL
            contactors = [0 1 0 0 1 1]; %GL off, GR off, AL power whole plane
        else 
            contactors = [0 0 0 0 0 0]; %all generators are broken ... good luck with that.
        end
    end

    %append on/off status for the B7-B12. B7,B8,B9,B10 are always on, and B11,B12 are always off
    contactors = [contactors 1 1 1 1 0 0]; 
end


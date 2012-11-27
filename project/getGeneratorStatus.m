% Returns a binary vector -- represents whether each generator is broken
% For now, I've hard-coded times for generators to fail. Could make this more sophisticated later.
% Assumes 3 generators are in the system

function genStatus = getGeneratorStatus(time)
    if(time < 50) 
        genStatus = [1 1 1];
    else
        genStatus = [1 0 1]; %Gen2 fails at time 50 (arbitrary)
    end
end


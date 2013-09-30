
% Hard-coded priority tables for now.

% Mehdi's simulation set all load shedding at equal priority. 
% If we were to set all loads to equal priority, then load shedding would just happen based on the loop ordering.
% So, as in Fig 3 of Mehdi's paper, I'm doing shedPriority = 1:10 for loads 1:10.

% Assume 2 buses, with 10 sheddable and 10 nonsheddable loads per bus
% Assume 3 generators 

function priTables = getPriorityTables()
    genPri1 = [0 1 2]; %Bus 1 gen priority (0 is most prefereed, 2 is least preferred)
    genPri2 = [1 0 2]; %Bus 2 gen priority

    sheddingPri1 = [1:10; 1:10]; %Bus 1 load shedding priority table (1 is most preferred to shed, 10 is least preferred)
    sheddingPri2 = [1:10; 1:10]; %Bus 2 load shedding priority table

    %sheddingPri notation:
    %sheddingPri1(1,:) = load numbers to shed (in ascending order)
    %sheddingPri2(2,:) = weight assigned to each of the loads to shed

    priTables = struct('genPri1', genPri1, 'genPri2', genPri2, 'sheddingPri1', sheddingPri1, 'sheddingPri2', sheddingPri2);
end



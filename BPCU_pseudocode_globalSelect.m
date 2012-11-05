

% for now, ignoring the "first turn stuff off; then turn stuff on" idea. will come back to this later.
% Later, we'll revise this to have one set of cases for *each contactor*, which decides the contactor's position based on the generator statuses. (basically turn the current code inside out)

% CASES
if GL and GR work
    [1 0 0 1 0 0] %GL power left, GR power right

if GL is broken and GR works
    if AL works
        [0 1 0 1 1 0] %GL off, GR power right, AL power left 
    else if AR works
        [0 0 1 1 1 0] %GL off, GR power right, AR power left  
    else
        [0 0 0 1 1 1] %GR power whole plane, everything else off

if GL works and GR is broken
    GR off
    GL power left
    if AR works
        [1 0 1 0 0 1] %GR off, GL power left, AR power right
    if AL works
        [1 1 0 0 0 1] %GR off, GL power left, AL power right
    else
        [1 0 0 0 1 1] %GL power whole plane, everything else off

if GL and GR are broken
    %it's arbitrary whether to use AL or AR in this case
    if AR works
        [0 0 1 0 1 1] %GL off, GR off, AR power whole plane
    else if AL works
        [0 1 0 0 1 1] %GL off, GR off, AL power whole plane
    %else all generators are broken, pwwwned.


%stuff that always happens:
    B7, B8, B9, B10 on
    B11, B12 off




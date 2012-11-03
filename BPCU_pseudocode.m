

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
        [0 1 0 0 1 1] %GL off, GR off, AR power whole plane
    else if AL works
        [0 1 0 0 1 1] %GL off, GR off, AL power whole plane
    %else all generators are broken, pwwwned.

% STATES (represent contactors on/off as boolean array [B1 B2 B3 B4 B5 B6])
% for now, an 'x' in the contactor array means 'dont care' or 'defer the other states to set this'
GL off:
    [0 x x x x x] %B1 off
GL power left:
    [1 x x x 0 x] %B1 on, B5 off
GL whole plane:
    [1 x x x 1 1] %B1, B5, B6 on

GR off:
    [x x x 0 x x] %B4 off
GR right:
    [x x x 1 x 0] %B4 on, B B6 off
GR whole plane:
    [x x x 1 1 1] %B4, B5, B6 on

AL off:
    [x 0 x x x x] %B2 off
AL left:
    [x 1 x x 1 0] %B2 on, B5 on, B6 off
AL right:
    [x 1 x x 0 1] %B2 on, B5 off, B6 on
AL whole plane:
    [x 1 x x 1 1] %B2, B5, B6 on

AR off:
    [x x 1 x x x] %B3 off
AR right:
    [x x 1 x 0 1] %B3 on, B5 off, B6 on
AR left:
    [x x 1 x 1 0] %B3 on, B5 on, B6 off
AR whole plane:
    [x x 1 x 1 1] %B3 on, B5 on, B6 on


%stuff that always happens:
    B7, B8, B9, B10 on
    B11, B12 off




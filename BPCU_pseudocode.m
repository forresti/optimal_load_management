

%for now, ignoring the "first turn stuff off; then turn stuff on" idea. will come back to this later.

% CASES
if GL and GR work
    GL power left
    GR power right

if GL is broken and GR works
    GL off
    GR power right
    if AL works
        AL power left 
    else if AR works
        AR power left 
    else
        GR power whole plane

if GL works and GR is broken
    GR off
    GL power left
    if AR works
        AR power right side
    if AL works
        AL power right side
    else
        GL power whole plane

if GL and GR are broken
    %it's arbitrary whether to use AL or AR in this case
    if AR works
        AR power whole plane
    else if AL works
        AL power whole plane
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
    %B4 off
GR right:
    %B4 on, B6 off
GR whole plane:
    %B4, B6, B6 on

AL off:
    %B2 off
AL left:
    %B2 on, B5 on, B6 off
AL right:
    %B2 on, B5 off, B6 on
AL whole plane:
    %B2, B5, B6 on

AR off:
    %B3 off
AR right:
    %B3 on, B5 off, B6 on
AR left:
    %B3 on, B5 on, B6 off
AR whole plane:
    %B3 on, B6 on, B6 on



%stuff that always happens:
    B7, B8, B9, B10 on
    B11, B12 off




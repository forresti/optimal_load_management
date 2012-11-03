

%for now, ignoring the "first turn stuff off; then turn stuff on" idea. will come back to this later.

% CASES
if GL and GR work
    GL power left
    GR power right

if GL is broken and GR works
    GL off
    (GR is initially in 'power right side' mode)
    if AL works
        AL power left side
    else if AR works
        AR power left side
    else
        GR power whole plane



if GL works and GR is broken
    GR off
    (GL initially in 'power left side' mode)
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

% STATES
GL off:
    B1 off

GL power left:
    B1, B7 on
    B5 off

GL whole plane:
    B1, B5, B6, B7 on


GR off:

GR right:

GR whole plane:


AL off:

AL left:

AL right:

AL whole plane:


AR off:

AR right:

AR left:

AR whole plane:    



%stuff that always happens:
    B7, B8, B9, B10 on
    B11, B12 off




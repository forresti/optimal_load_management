function config = LLLMS(system)
gen1 = system.('gen1');
gen2 = system.('gen2');
apu = system.('apu');

gen = [1, 2]; % optimal
if (gen1 == 0)
    if (gen2 == 0)
        gen(0) = 3;
    else
        gen(0) = 2;
    end
end

if (gen2 == 0)
    if (gen1 == 0)
        gen(1) = 3;
    else
        gen(1) = 1;
    end
end

% determine power draw from each generator & adjust to not exceed power
% rating
b1NSPwrReq = system.('b1NSPwrReq');
b1SPwrReq = system.('b1SPwrReq');
b2NSPwrReq = system.('b2NSPwrReq');
b2SPwrReq = system.('b2SPwrReq');

pwrReqGen1 = 0;
pwrReqGen2 = 0;
pwrReqApu = 0;

if (gen(0) == 1)
    pwrReqGen1 = b1NSPwrReq + b1SPwrReq;
end
if (gen(0) == 2)
    pwrReqGen2 = b1NSPwrReq + b1SPwrReq;
end
if (gen(0) == 3)
    pwrReqApu = b1NSPwrReq + b1SPwrReq;
end

if (gen(1) == 1)
    pwrReqGen1 = pwrReqGen1 + b2NSPwrReq + b2SPwrReq;
end
if (gen(1) == 2)
    pwrReqGen2 = pwrReqGen2 + b2NSPwrReq + b2SPwrReq;
end
if (gen(1) == 3)
    pwrReqApu = pwrReqApu + b2NSPwrReq + b2SPwrReq;
end

loadTbl1 = system.('loadTbl1');
loadTbl2 = ssytem.('loadTbl2');
load1Shed = zeroes(1, 10);
load2Shed = zeroes(1, 10);
priority = 10;
while (pwrReqGen1 > 5000)
    if (gen(1) == 1) % remove sheddable load from right side first
        pwrReqGen1 = pwrReqGen1 - loadTbl2(priorty);
        load2Shed(priority) = 1;
    end
    if (gen(0) == 1 && pwrReqGen1 > 5000) % now do it for the left side if still over
        pwrReqGen1 = pwrReqGen1 - loadTbl1(priority);
        load1Shed(priority) = 1;
    end
    priority = priority - 1;
end

priority = 10;
while (pwrReqGen2 > 5000)
    if (gen(0) == 2) % remove sheddable load from left side first
        pwrReqGen2 = pwrReqGen2 - loadTbl1(priorty);
        load1Shed(priority) = 1;
    end
    if (gen(1) == 2 && pwrReqGen2 > 5000) % now do it for the right side if still over
        pwrReqGen2= pwrReqGen2 - loadTbl2(priority);
        load2Shed(priority) = 1;
    end
    priority = priority - 1;
end

priority = 10;
while (pwrReqApu > 5000)
    if (gen(0) == 3) % remove sheddable load from left side first
        pwrReqApu = pwrReqApu - loadTbl1(priorty);
        load1Shed(priority) = 1;
    end
    if (gen(1) == 3 && pwrReqGen2 > 5000) % now do it for the right side if still over
        pwrReqApu = pwrReqApu - loadTbl2(priority);
        load2Shed(priority) = 1;
    end
    priority = priority - 1;
end

config = [gen, load1Shed, load2Shed];
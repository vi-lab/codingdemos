function [ HUFFVAL, BITS ] = generateHuffmanCodeLengthAndSymbolTablesFromData( data )
%GENERATEHUFFMANCODELENGTHANDSYMBOLTABLESFROMDATA Summary of this function goes here
%   Detailed explanation goes here

% Ref: ISO/IEC 10918-1 : 1993(E), Section K.2, p. 144-148

% Count data
FREQ = zeros(1,257);
FREQ(257) = 1;
FREQ(1:256) = hist(double(data(:)), 0.5:1:255.5);
CODESIZE = zeros(1,257);
OTHERS = ones(1,257).*-1;



condition1 = true;

while (condition1)
    %V1
    freqGTZero = FREQ(:);
    freqGTZero(freqGTZero <= 0) = 1000000;
    mF = min(freqGTZero);
    if mF == 1000000
        break;
    end
    leastVs = find(freqGTZero == mF);
    %[vals leastVs] = min(freqGTZero);
    V1 = max(leastVs);
    % remove least vals to find next least vals
    freqGTZero(leastVs) = 1000000;
    %[vals leastVs] = min(freqGTZero);
    mF = min(freqGTZero);
    if mF == 1000000
        break;
    end
    leastVs = find(freqGTZero == mF);

    if isempty(leastVs)
        break;
    end

    V2 = max(leastVs);

    FREQ(V1) = FREQ(V1) + FREQ(V2);
    FREQ(V2) = 0;

    condition2 = true;
    while(condition2)
        CODESIZE(V1) = CODESIZE(V1) + 1;
        condition2 = (OTHERS(V1) ~= -1);
        if condition2
            V1 = OTHERS(V1);
        end
    end

    OTHERS(V1) = V2;

    condition2 = true;
    while(condition2)
        CODESIZE(V2) = CODESIZE(V2) + 1;
        condition2 = (OTHERS(V2) ~= -1);
        if condition2
            V2 = OTHERS(V2);
        end
    end
end

% Count_BITS, Fig K.2, p 146
BITS = zeros(1,257);
I = 1;
condition1 = true;
while(condition1)
    if CODESIZE(I) ~= 0
        BITS(CODESIZE(I)) = BITS(CODESIZE(I)) + 1;
    end
    condition1 = (I ~= 257);
    I = I + 1;
end

% Adjust_BITS
I = 33;%32;

while(true)
    if BITS(I) > 0
        J = I - 1;
        condition1 = true;
        while condition1
            J = J - 1;
            condition1 = (BITS(J) <= 0);
        end
        BITS(I) = BITS(I) - 2;
        BITS(I - 1) = BITS(I - 1) + 1;
        BITS(J + 1) = BITS(J + 1) + 2;
        BITS(J) = BITS (J) - 1;
    else
        I = I - 1;
        if I == 17%16
            while BITS(I) == 0
                I = I - 1;
            end
            BITS(I) = BITS(I) - 1;
            break;
        end
    end
end

BITS(17:end) = [];

%Sort_input
HUFFVAL = [];
I = 1;
K = 1;
condition1 = true;
while condition1
    J = 1;
    condition2 = true;
    while condition2
        if CODESIZE(J) == I
            HUFFVAL(K) = J; 
            K = K + 1;
        end
        J = J + 1;
        condition2 = (J <= 256);
    end
    I = I + 1;
    condition1 = (I <= 32);
end

end
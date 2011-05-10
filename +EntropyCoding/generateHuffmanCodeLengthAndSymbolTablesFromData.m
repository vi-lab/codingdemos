function [ HUFFVAL, BITS ] = generateHuffmanCodeLengthAndSymbolTablesFromData( data )
%GENERATEHUFFMANCODELENGTHANDSYMBOLTABLESFROMDATA Summary of this function goes here
%
%   +EntropyCoding/generateHuffmanCodeLengthAndSymbolTablesFromData.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Generates the 2 Huffman tables needed to generate the Huffman code
%   table (as specified by the JPEG standard) for the data provided.
%   From the data is extracted the symbols in the input and their
%   relative frequency and this is used in the process described in
%   the standard to generate the custom HUFFVAL & BITS tables for the
%   current image. Creating Huffman code tables with the data provided
%   means the code lengths are optimised for the actual data (unlike the
%   tables provided in the standard that are optimised across a range of 
%   natural input images) and thus gives the best compression performance.
%   The input data will be something like either all the RS values for all
%   coefficients of all blocks in a image channel, or the magnitude
%   categories for all DC differential values for all blocks in a given
%   channel.
%   
%   This method contains implementations of the methods Count_BITS,
%   Adjust_BITS and Sort_input as specified in the standard.
%
%   Ref: ISO/IEC 10918-1 : 1993(E), Section K.2, p. 144-148
%
%   Parameters -
%       data: the input data array (e.g. the RS values for all coefficients of all blocks of the luminance channel)
%   Returns -
%       HUFFVAL: the table of symbols for each Huffman code
%       BITS: the Huffman codes counts per code length
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% Count data
FREQ = zeros(1,257);
FREQ(257) = 1;
FREQ(1:256) = hist(double(data(:)), 0:1:255);
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
HUFFVAL = zeros(1,256);
I = 1;
K = 1;
condition1 = true;
while condition1
    J = 0;
    condition2 = true;
    while condition2
        if CODESIZE(J+1) == I
            HUFFVAL(K) = J; 
            K = K + 1;
        end
        J = J + 1;
        condition2 = (J <= 255);
    end
    I = I + 1;
    condition1 = (I <= 32);
end
HUFFVAL(K:end) = [];
end
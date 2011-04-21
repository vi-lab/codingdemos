function [HUFFSIZE, LASTK] = generateTableOfHuffmanCodeSizes( BITS )
%GENERATETABLEOFHUFFMANCODESIZES Summary of this function goes here
%
%   +EntropyCoding/ChromaACHuffmanCodeCountPerCodeLength.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Ref: CCITT Rec. T.81 (1992 E) p. 51, Figure C.1
%
%   HELP INFO
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

conditionA = false;

K = 1; % matlab arrays indexed from 1
I = 1;
J = 1;

HUFFSIZE = [];

while ~conditionA
    while ~(J > BITS(I))
        HUFFSIZE(K) = I;
        K = K + 1;
        J = J + 1;
    end
    I = I + 1;
    J = 1;
    conditionA = (I > 16);
end


HUFFSIZE(K) = 0;
LASTK = K;


end

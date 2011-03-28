function [HUFFSIZE, LASTK] = generateTableOfHuffmanCodeSizes( BITS )
%GENERATETABLEOFHUFFMANCODESIZES Summary of this function goes here
%   DESCRIBE
%   
%   Ref: CCITT Rec. T.81 (1992 E) p. 51, Figure C.1

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

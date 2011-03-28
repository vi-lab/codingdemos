function [ HUFFCODE ] = generateTableOfHuffmanCodes( HUFFSIZE )
%GENERATETABLEOFHUFFMANCODES Summary of this function goes here
%   DESCRIBE
%   
%   Ref: CCITT Rec. T.81 (1992 E) p. 52, Figure C.2

K = 1;
CODE = uint16(0);
SI = HUFFSIZE(1);

% use these to emulate do-while loops as per the flow diagrams in the spec
conditionA = true;

while conditionA
    conditionB = true;
    while conditionB
        HUFFCODE(K) = CODE;
        CODE = CODE + 1;
        K = K + 1;
        conditionB = (HUFFSIZE(K) == SI);
    end
    if HUFFSIZE(K) == 0
        break;
    end
    
    conditionA = false;
    while ~conditionA
        CODE = bitshift(CODE, 1);
        SI = SI + 1;
        conditionA = (HUFFSIZE(K) == SI);
    end
end


end

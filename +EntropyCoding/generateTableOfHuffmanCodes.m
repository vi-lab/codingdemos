function [ HUFFCODE ] = generateTableOfHuffmanCodes( HUFFSIZE )
%GENERATETABLEOFHUFFMANCODES Create the table of Huffman code values given the array of Huffman code sizes
%
%   +EntropyCoding/generateTableOfHuffmanCodes.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   This is an implementation of the method 'Generate_code_table' in the
%   JPEG standard. Given an array of the size of each Huffman code this
%   actually generates the Huffman codes. The codes are ordered by
%   increasing code value and length.
%
%   Ref: CCITT Rec. T.81 (1992 E) p. 52, Figure C.2
%
%   Parameters -
%       HUFFSIZE: a table of the size of each Huffman code
%   Returns -
%       HUFFCODE: a table of the Huffman codes (in numeric values)
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% FIXME: vectorise but leave commented out implementation of flowchart

K = 1;
CODE = uint16(0);
SI = HUFFSIZE(1);
HUFFCODE = zeros(1,length(HUFFSIZE));
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

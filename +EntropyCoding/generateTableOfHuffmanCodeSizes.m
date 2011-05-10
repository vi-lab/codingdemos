function [HUFFSIZE, LASTK] = generateTableOfHuffmanCodeSizes( BITS )
%GENERATETABLEOFHUFFMANCODESIZES Generate a table of the bit size of each Huffman code
%
%   +EntropyCoding/generateTableOfHuffmanCodeSizes.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Given the BITS array or table of Huffman code length counts, generate
%   a table of the length of each Huffman code. This method is an
%   implementation of the 'Generate_size_table' flow diagram in the
%   standard.
%
%   Ref: CCITT Rec. T.81 (1992 E) p. 51, Figure C.1
%
%   Parameters -
%       BITS: the table of Huffman code length counts, i.e. the number of Huffman codes per bit length
%   Returns -
%       HUFFSIZE: a table of the size of each Huffman code
%       LASTK: the last code index, ie the number of codes
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% FIXME: vectorise this (but leave in commented out implementation as per standard flowdiagram)

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

function [ MINCODE MAXCODE VALPTR ] = generateDecodingProcedureTable( BITS, HUFFCODE )
%GENERATEDECODINGPROCEDURETABLE Generate the tables to be used by the JPEG DECODE procedure
%
%   +EntropyCoding/generateDecodingProcedureTable.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Implementation of the method 'Decoder_tables' as defined in the JPEG
%   standard. MINCODE(I) and MAXCODE(I) contain the Huffman min/max code
%   values for codes of length I. VALPTR(I) contains the index of the
%   first symbol value in the HUFFVALS array presented by code length I.
%
%   Ref: CCITT Rec. T.81 (1992 E) p.107-108, Figure F.15
%
%   Parameters -
%       BITS: the Huffman code length counts array
%       HUFFCODE: the Huffman codes array
%   Returns -
%       MINCODE: the minimum Huffman code values per code length
%       MAXCODE: the maximum Huffman code values per code length
%       VALPTR: the index to the first symbol in to the Huffman Symbol table for each code length
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

I = 1;
J = 1;

while I <= 16
    
    if BITS(I) == 0
        MAXCODE(I) = -1;
    else
        VALPTR(I) = J;
        MINCODE(I) = HUFFCODE(J);
        J = J + BITS(I) - 1;
        MAXCODE(I) = HUFFCODE(J);
        J = J + 1;
    end
    
    I = I + 1;
end

MAXCODE = int16(MAXCODE);

end

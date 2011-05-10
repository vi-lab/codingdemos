function [ table ] = ChromaACHuffmanCodeCountPerCodeLength( )
%ChromaACHuffmanCodeCountPerCodeLength Standard Chroma AC Huffman Code Counts table
%
%   +EntropyCoding/ChromaACHuffmanCodeCountPerCodeLength.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Constant table of Huffman code counts for AC chroma coefficients as
%   specified by the standard (the BITS table).
%
%   Ref: CCITT Rec. T.81 (1992 E) p.159 Section K.3.3.2
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

table = [0 2 1 2 4 4 3 4 7 5 4 4 0 1 2 119];

end

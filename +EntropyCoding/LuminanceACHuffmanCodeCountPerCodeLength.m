function [ table ] = LuminanceACHuffmanCodeCountPerCodeLength( )
%LuminanceACHuffmanCodeCountPerCodeLength The BITS array for the luminance AC Huffman tables
%
%   +EntropyCoding/ChromaACHuffmanCodeCountPerCodeLength.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Ref: CCITT Rec. T.81 (1992 E) p. 158, Table K.5
%
%   The BITS array for the luminance AC Huffman tables as recommended by
%   the standard.
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

table = [0 2 1 3 3 2 4 3 5 5 4 4 0 0 1 125];

end

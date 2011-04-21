function [ table ] = LuminanceDCHuffmanCodeCountPerCodeLength(  )
%LUMINANCEDCHUFFMANCODECOUNTPERCODELENGTH The BITS array for the luminance DC Huffman tables
%
%   +EntropyCoding/ChromaACHuffmanCodeCountPerCodeLength.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Ref: CCITT Rec. T.81 (1992 E) p. 158, Table K.3
%
%   The BITS array for the luminance DC Huffman tables as recommended by
%   the standard.
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

table = [0 1 5 1 1 1 1 1 1 0 0 0 0 0 0 0];

end

function [ table ] = luminanceQuantisationTable( )
%LUMINANCEQUANTISATIONTABLE The standard luminance DCT quantisation table
%
%   +TranformCoding/luminanceQuantisationTable.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   The standard quantisation table for the luminance channel.
%
%   Ref: CCITT Rec. T.81 (1992 E) p. 143, Section K.1
%
%   Returns -
%       table: the quantisation matrix
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

table = [
        16  11  10  16  24  40  51  61
        12  12  14  19  26  58  60  55
        14  13  16  24  40  57  69  56
        14  17  22  29  51  87  80  62
        18  22  37  56  68  109 103 77
        24  35  55  64  81  104 113 92
        49  64  78  87  103 121 120 101
        72  92  95  98  112 100 103 99];
end

function [ table ] = chromaQuantisationTable( )
%CHROMAQUANTISATIONTABLE The standard chroma DCT quantisation table
%
%   +TranformCoding/chromaQuantisationTable.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   The standard quantisation table for chroma channels.
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
        17  18  24  47  99  99  99  99
        18  21  26  66  99  99  99  99
        24  26  56  99  99  99  99  99
        47  66  99  99  99  99  99  99
        99  99  99  99  99  99  99  99
        99  99  99  99  99  99  99  99
        99  99  99  99  99  99  99  99
        99  99  99  99  99  99  99  99];
end

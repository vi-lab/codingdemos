function [ EHUFCO, EHUFSI ] = generateEncodingProcedureCodeTables( HUFFVAL, HUFFCODE, HUFFSIZE, LASTK )
%GENERATEENCODINGPROCEDURECODETABLES Summary of this function goes here
%
%   +EntropyCoding/generateEncodingProcedureCodeTables.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Ref: CCITT Rec. T.81 (1992 E) p. 53, Figure C.3
%
%   HELP INFO
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

K = 1;
conditionA = true;

while conditionA
    I = HUFFVAL(K);
    EHUFCO(I+1) = HUFFCODE(K);
    EHUFSI(I+1) = HUFFSIZE(K);
    K = K + 1;
    conditionA = (K < LASTK);
end 


end

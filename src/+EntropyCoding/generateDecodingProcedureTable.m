function [ MINCODE MAXCODE VALPTR ] = generateDecodingProcedureTable( BITS, HUFFCODE )
%GENERATEDECODINGPROCEDURETABLE Summary of this function goes here
%   Detailed explanation goes here
%
%   +EntropyCoding/generateDecodingProcedureTable.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   HELP INFO
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

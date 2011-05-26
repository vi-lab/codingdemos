function [ array ] = logicalArrayToUnsignedNumericArray( binaryArray, padding )
%LOGICALARRAYTOUNSIGNEDNUMERICARRAY Convert the logical bit array to an unsigned numeric array with padding value specified
%
%   +Utilites/logicalArrayToUnsignedNumericArray.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Note this method assumes 8 bit bytes.
%
%   Parameters -
%       binaryArray: the logical binary bit array
%   Optional Parameters -
%       padding: the value (1 or 0, 1 by default) to pad with
%   Returns -
%       array: the unsigned numeric array
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if ~exist('padding', 'var')
    padding = 1;
end
paddedArray = Utilities.padLogicalArray(binaryArray, 8, padding);
array = uint8(Utilities.logicalToUnsignedDecimal(reshape(paddedArray, 8, []).'));
end

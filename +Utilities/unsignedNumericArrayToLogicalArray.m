function [ logicalArray ] = unsignedNumericArrayToLogicalArray( array )
%UNSIGNEDNUMERICARRAYTOLOGICALARRAY Convert the unsigned numeric array to a logical bit array
%
%   +Utilites/unsignedNumericArrayToLogicalArray.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Note this method assumed 8 bit bytes.
%
%   Parameters -
%       array: the unsigned numeric array
%   Returns -
%       logicalArray: the logical binary bit array
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

logicalArray = cell2mat(arrayfun(@(x)(Utilities.decimalToByte(x)), array.', 'UniformOutput', false));

%{
len = length(binaryArray);
array = [];

for i=1:8:len
    if i + 7 > len
        lastBits = binaryArray(i:(i + (len - i)));
        paddingBits = logical(ones(1, 7 - (len - i)) .* padding);
        array = cat(2, array, Utilities.logicalToUnsignedDecimal([lastBits paddingBits]));
    else
        array = cat(2, array, Utilities.logicalToUnsignedDecimal(binaryArray(i:i + 7)));
    end
end
%}
end

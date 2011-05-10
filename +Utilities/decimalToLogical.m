function [ binary ] = decimalToLogical( dec, lengthInBits )
%DECIMALTOLOGICAL Convert integer values to logical binary arrays
%
%   +Utilities/decimalToLogical.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   This method converts a single or an array of decimal values into binary
%   logical arrays of bytes of 'lengthInBits' length. Negative 'dec' values
%   are converted to 2's compliment binary.
%
%   Parameters -
%       dec: a single or array of integer values
%       lengthInBits: the size of the bytes to create in number of bits
%   Returns -
%       binary: if 'dec' is a single number then the output is the logical
%               array result, else a matrix is returned containing the
%               binary results on each row for each value of 'dec'
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if ~isnumeric(dec)
    throw(MException('Utilities:decimalToLogical', 'The decimal must be a numeric value.'));
end

if nnz(dec < 0)
    dec = Utilities.decimalToTwosComplimentDecimal(dec, lengthInBits);
end

binary = logical('1'==dec2bin(dec, lengthInBits));
if lengthInBits < size(binary,2)
    throw(MException('Utilities:decimalToLogical', 'The number can not fit in the specified number of bits.'));
end

end
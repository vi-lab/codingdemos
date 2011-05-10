function [ value ] = decimalToTwosComplimentDecimal( dec, lengthInBits )
%DECIMALTOTWOSCOMPLIMENTDECIMAL Return the unsigned decimal values of the given negative decimal
%
%   +Utilites/decimalToTwosComplimentDecimal.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Parameters -
%       dec: the negative value to cast
%       lengthInBits: the length in bits of the cast value
%   Returns -
%       value: the unsigned value
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if ~exist('lengthInBits', 'var')
    lengthInBits = 8;
end

if ~(dec < 0)
    throw(MException('Utilities:decimalTwosCompliment', 'You can only get the 2''s compliment of a negative number.'));
end

if lengthInBits < 9
    decCast = typecast(int8(dec), 'uint8');
elseif lengthInBits < 17
    decCast = typecast(int16(dec), 'uint16');
elseif lengthInBits < 33
    decCast = typecast(int32(dec), 'uint32');
end

mask = (2^lengthInBits) - 1;
value = bitand(decCast, mask); % strop off unwanted bits

end

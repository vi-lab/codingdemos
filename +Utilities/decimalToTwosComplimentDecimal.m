function [ value ] = decimalToTwosComplimentDecimal( dec, lengthInBits )
%TWOSCOMPLIMENT Summary of this function goes here
%   Detailed explanation goes here

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

% Below is the old very slow way
%binary = num2str('0'==dec2bin(abs(dec), lengthInBits), '%d');
%if lengthInBits < length(binary)
%    throw(MException('Utilities:decimalTwosCompliment', 'The number can not fit in the specified number of bits.'));
%end
%value = bin2dec(binary) + 1;

end

function [ value ] = decimalToTwosComplimentDecimal( dec, lengthInBits )
%TWOSCOMPLIMENT Summary of this function goes here
%   Detailed explanation goes here

if ~exist('lengthInBits', 'var')
    lengthInBits = 8;
end

if ~(dec < 0)
    throw(MException('Utilities:decimalTwosCompliment', 'You can only get the 2''s compliment of a negative number.'));
end

binary = num2str('0'==dec2bin(abs(dec), lengthInBits), '%d');

if lengthInBits < length(binary)
    throw(MException('Utilities:decimalToBinary', 'The number can not fit in the specified number of bits.'));
end

value = bin2dec(binary) + 1;

end

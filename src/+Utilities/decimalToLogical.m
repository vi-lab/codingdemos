function [ binary ] = decimalToLogical( dec, lengthInBits )
%DECIMALTOBINARY Summary of this function goes here
%   Detailed explanation goes here

if ~isnumeric(dec)
    throw(MException('Utilities:decimalToLogical', 'The decimal must be a numeric value.'));
end

%negative numbers in 2s compliment

if (dec < 0)
    %bin2dec(num2str('0'==dec2bin(abs(-10), 8), '%d'))
    binary = logical('1'==dec2bin(Utilities.decimalToTwosComplimentDecimal( dec, lengthInBits), lengthInBits));
else
    binary = logical('1'==dec2bin(dec, lengthInBits));
end

if lengthInBits < length(binary)
    throw(MException('Utilities:decimalToLogical', 'The number can not fit in the specified number of bits.'));
end

end

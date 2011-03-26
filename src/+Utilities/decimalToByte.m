function [ byte ] = decimalToByte( dec )
%DECIMALTOBYTE Summary of this function goes here
%   Detailed explanation goes here

if ~isnumeric(dec)
    throw(MException('Utilities:decimalToByte', 'The decimal must be a numeric value in the range of a uint8.'));
end

byte = logical('1'==dec2bin(uint8(dec), 8));

end

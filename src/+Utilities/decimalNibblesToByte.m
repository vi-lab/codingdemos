function [ byte ] = decimalNibblesToByte( nhigh, nlow )
%DECIMALNIBBLESTOBYTE Summary of this function goes here
%   Detailed explanation goes here

if ~isnumeric(nhigh) && ~isnumeric(nlow)
    throw(MException('Utilities:decimalNibblesToByte', 'The decimals must be numeric values. Each will be truncated to 4 bits.'));
end

byte = [logical('1'==dec2bin(uint8(nhigh), 4)) logical('1'==dec2bin(uint8(nlow), 4))];

end

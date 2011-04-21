function [ byte ] = decimalNibblesToByte( nhigh, nlow )
%DECIMALNIBBLESTOBYTE Summary of this function goes here
%   Detailed explanation goes here

if ~isnumeric(nhigh) && ~isnumeric(nlow) && ~(nhigh < 0) && ~(nlow < 0)
    throw(MException('Utilities:decimalNibblesToByte', 'The decimals must be positive numeric values. Each will be truncated to 4 bits.'));
end

byte = [Utilities.decimalToLogical(uint8(nhigh), 4) Utilities.decimalToLogical(uint8(nlow), 4)];
end

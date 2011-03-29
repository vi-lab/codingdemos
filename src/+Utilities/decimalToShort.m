function [ short ] = decimalToShort( dec )
%DECIMALTOWORD Summary of this function goes here
%   Detailed explanation goes here

if ~isnumeric(dec)
    throw(MException('Utilities:decimalToShort', 'The decimal must be a numeric value in the range of a uint16.'));
end

%short = logical('1'==dec2bin(uint16(dec), 16));
short = Utilities.decimalToLogical(dec, 16);

end

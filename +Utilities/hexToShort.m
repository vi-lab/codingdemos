function [ short ] = hexToShort( hexStr )
%HEXTOWORD Summary of this function goes here
%   Detailed explanation goes here

if ~ischar(hexStr)
    throw(MException('Utilities:hexToShort', 'The hex number must be in string format'));
end

short = logical('1'==dec2bin(hex2dec(hexStr), 16));

end

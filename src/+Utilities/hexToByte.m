function [ byte ] = hexToByte( hexStr )
%HEXTOBYTE Summary of this function goes here
%   Detailed explanation goes here

if ~ischar(hexStr)
    throw(MException('Utilities:hexToByte', 'The hex number must be in string format'));
end

byte = logical('1'==dec2bin(hex2dec(hexStr), 8));

end

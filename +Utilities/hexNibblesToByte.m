function [ byte ] = hexNibblesToByte( nhigh, nlow )
%HEXNIBBLESTOBYTE Summary of this function goes here
%   Detailed explanation goes here

if ~ischar(nhigh) && ~ischar(nlow)
    throw(MException('Utilities:hexNibblesToByte', 'The hex values must be string values. Each will be truncated to 4 bits.'));
end

byte = [logical('1'==dec2bin(hex2dec(nhigh), 4)) logical('1'==dec2bin(hex2dec(nlow), 4))];

end

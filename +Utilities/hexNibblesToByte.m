function [ byte ] = hexNibblesToByte( nhigh, nlow )
%HEXNIBBLESTOBYTE Convert 2 4-bit hex values into a packed byte
%
%   +Utilites/hexNibblesToByte.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Parameters -
%       nhigh: the hex string value of the high 4 bits
%       nlow: the hex string value of the lower 4 bits
%   Returns -
%       byte: the 8 bit logical bit array
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if ~ischar(nhigh) && ~ischar(nlow)
    throw(MException('Utilities:hexNibblesToByte', 'The hex values must be string values. Each will be truncated to 4 bits.'));
end

byte = [logical('1'==dec2bin(hex2dec(nhigh), 4)) logical('1'==dec2bin(hex2dec(nlow), 4))];

end

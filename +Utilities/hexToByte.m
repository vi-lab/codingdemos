function [ byte ] = hexToByte( hexStr )
%HEXTOBYTE Convert the hex value to an 8-bit logical bit array
%
%   +Utilites/hexToByte.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Parameters -
%       hexStr: the hex string value to convert
%   Returns -
%       byte: the 8 bit logical bit array
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if ~ischar(hexStr)
    throw(MException('Utilities:hexToByte', 'The hex number must be in string format'));
end

byte = logical('1'==dec2bin(hex2dec(hexStr), 8));

end

function [ short ] = hexToShort( hexStr )
%HEXTOSHORT Convert the hex value to a 16-bit logical bit array
%
%   +Utilites/hexToShort.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Parameters -
%       hexStr: the hex string value to convert
%   Returns -
%       short: the 16 bit logical bit array
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if ~ischar(hexStr)
    throw(MException('Utilities:hexToShort', 'The hex number must be in string format'));
end

short = logical('1'==dec2bin(hex2dec(hexStr), 16));

end

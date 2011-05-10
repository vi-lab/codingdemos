function [ byte ] = decimalNibblesToByte( nhigh, nlow )
%DECIMALNIBBLESTOBYTE Convert 2 4-bit decimal values into a packed byte
%
%   +Utilites/decimalNibblesToByte.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Parameters -
%       nhigh: the decimal value of the high 4 bits
%       nlow: the decimal value of the lower 4 bits
%   Returns -
%       byte: the 8 bit logical bit array
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if ~isnumeric(nhigh) && ~isnumeric(nlow) && ~(nhigh < 0) && ~(nlow < 0)
    throw(MException('Utilities:decimalNibblesToByte', 'The decimals must be positive numeric values. Each will be truncated to 4 bits.'));
end

byte = [Utilities.decimalToLogical(uint8(nhigh), 4) Utilities.decimalToLogical(uint8(nlow), 4)];
end

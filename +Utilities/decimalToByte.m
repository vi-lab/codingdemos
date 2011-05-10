function [ byte ] = decimalToByte( dec )
%DECIMALTOBYTE Convert the decimal value to an 8-bit logical bit array
%
%   +Utilites/decimalToByte.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Parameters -
%       dec: the value to convert
%   Returns -
%       byte: the 8 bit logical bit array
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% FIXME: vectorise (allow vector inputs)

if ~isnumeric(dec)
    throw(MException('Utilities:decimalToByte', 'The decimal must be a numeric value.'));
end
% clamp at range
if dec < -128
    dec = -128;
end
if dec > 127
    dec = 127;
end

byte = Utilities.decimalToLogical(dec, 8);

end

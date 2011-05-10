function [ short ] = decimalToShort( dec )
%DECIMALTOSHORT Convert the decimal value to a 16-bit logical bit array
%
%   +Utilites/decimalToShort.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Parameters -
%       dec: the value to convert
%   Returns -
%       byte: the 16 bit logical bit array
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% FIXME: vectorise (allow vector inputs)

if ~isnumeric(dec)
    throw(MException('Utilities:decimalToShort', 'The decimal must be a numeric value in the range of a uint16.'));
end
if dec < -32768
    dec = -32768;
end
if dec > 32767
    dec = 32767;
end

short = Utilities.decimalToLogical(dec, 16);

end

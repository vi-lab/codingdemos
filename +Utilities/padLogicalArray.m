function [ paddedArray ] = padLogicalArray( array, byteLength, padValue )
%PADLOGICALARRAY Pad a logical bit array to a given byte length
%
%   +Utilities/padLogicalArray.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Extend the length of a binary logical bit array to a factor of the
%   given byte length with the given pad value.
%
%   Parameters -
%       array: a logical binary array
%       byteLength: the length of a byte in the logical array, defaults to 8 bits
%       padValue: 1 or 0 pad value, defaults to 1
%   Returns -
%       paddedArray: the padded array
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if ~exist('byteLength', 'var')
    byteLength = 8;
end

if ~exist('padValue', 'var')
    padValue = 1;
end

padLength = byteLength - rem(length(array), byteLength);
if padLength < byteLength
    paddedArray = cat(2, array, logical(ones(1, padLength).*padValue));
else
    paddedArray = array;
end

end

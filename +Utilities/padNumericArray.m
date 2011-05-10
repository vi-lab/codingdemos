function [ paddedArray ] = padNumericArray( array, padValue, lengthWithPadding )
%PADNUMERICARRAY Pad a numeric array to a given length with the given value
%
%   +Utilities/padNumericArray.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Extend the length of a numeric array to the specified length with the
%   given padding value.
%
%   Parameters -
%       array: the numeric array
%       lengthWithPadding: the final array length
%       padValue: the numeric pad value
%   Returns -
%       paddedArray: the padded array
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

paddedArray = ones(1, lengthWithPadding) .* padValue;
paddedArray(1:length(array)) = array;

if length(paddedArray) > lengthWithPadding
    disp('WARNING: Input array is larger than desired array with pad! Array will be trimmed.');
    paddedArray(lengthWithPadding+1:end) = [];
end

end

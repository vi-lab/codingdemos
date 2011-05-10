function [ dec ] = logicalToSignedDecimal( array )
%LOGICALTOSIGNEDDECIMAL Convert binary logical arrays to signed decimals
%
%   +Utilities/logicalToSignedDecimal.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   This method converts a single or a matrix of binary logical arrays
%   into signed decimal values.
%
%   Parameters -
%       data: a logical array or a matrix of rows of logical arrays
%   Returns -
%       dec: the signed decimal values array
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.
%
%   Note: this is slow
%

if ~islogical(array) && ~isnumeric(array)
    throw(MException('Utilities:logicalToDecimal', 'The binary array must be either numeric or logical.'));
end

%dec = bin2dec(num2str(array, '%d'));
for i=1:size(array,1)
    if array(i,1) == 1
        % negative
        dec(i) = (-1*bin2dec(num2str(0==array(i,:), '%d'))) - 1;
    else
        dec(i) = bin2dec(num2str(array(i,:), '%d'));
    end
end

end

function [ dec ] = logicalToUnsignedDecimal( data )
%LOGICALTOUNSIGNEDDECIMAL Convert binary logical arrays to unsigned decimal
%
%   +Utilities/logicalToUnsignedDecimal.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   This method converts a single or a matrix of binary logical arrays
%   into unsigned decimal values.
%
%   Parameters -
%       data: a logical array or a matrix of rows of logical arrays
%   Returns -
%       dec: the unsigned decimal values array
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.
%

if ~islogical(data)
    throw(MException('Utilities:logicalToDecimal', 'The binary array must be a logical array or a matrix containing logical arrays as rows.'));
end

multiplicands = 2.^(size(data,2)-1:-1:0);

dec = sum(data .* repmat(multiplicands, size(data,1), 1), 2);

end

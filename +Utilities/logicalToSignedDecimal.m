function [ dec ] = logicalToSignedDecimal( array )
%LOGICALTWOSCOMPLIMENTTODECIMAL Summary of this function goes here
%   Detailed explanation goes here

if ~islogical(array) && ~isnumeric(array)
    throw(MException('Utilities:logicalToDecimal', 'The binary array must be either numeric or logical.'));
end

%dec = bin2dec(num2str(array, '%d'));
if array(1) == 1
    % negative
    dec = (-1*bin2dec(num2str(0==array, '%d'))) - 1;
else
    dec = bin2dec(num2str(array, '%d'));
end


end

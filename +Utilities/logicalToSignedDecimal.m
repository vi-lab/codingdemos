function [ dec ] = logicalToSignedDecimal( array )
%LOGICALTWOSCOMPLIMENTTODECIMAL Summary of this function goes here
%   Detailed explanation goes here
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

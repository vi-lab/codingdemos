function [ dec ] = logicalToUnsignedDecimal( array )
%LOGICALTODECIMAL Summary of this function goes here
%   Detailed explanation goes here

if ~islogical(array) && ~isnumeric(array)
    throw(MException('Utilities:logicalToDecimal', 'The binary array must be either numeric or logical.'));
end

dec = bin2dec(num2str(array, '%d'));

end

function [ logicalArray ] = unsignedNumericArrayToLogicalArray( array )
%BINARYTONUMERICARRAY Summary of this function goes here
%   Detailed explanation goes here

logicalArray = cell2mat(arrayfun(@(x)(Utilities.decimalToByte(x)), array.', 'UniformOutput', false));

%{
len = length(binaryArray);
array = [];

for i=1:8:len
    if i + 7 > len
        lastBits = binaryArray(i:(i + (len - i)));
        paddingBits = logical(ones(1, 7 - (len - i)) .* padding);
        array = cat(2, array, Utilities.logicalToUnsignedDecimal([lastBits paddingBits]));
    else
        array = cat(2, array, Utilities.logicalToUnsignedDecimal(binaryArray(i:i + 7)));
    end
end
%}
end

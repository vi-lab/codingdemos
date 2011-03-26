function [ array ] = binaryToNumericArray( binaryArray, padding )
%BINARYTONUMERICARRAY Summary of this function goes here
%   Detailed explanation goes here

if ~exist('padding', 'var')
    padding = 1;
end

len = length(binaryArray);
array = [];

for i=1:8:len
    if i + 7 > len
        lastBits = binaryArray(i:(i + (len - i)));
        paddingBits = logical(ones(1, 7 - (len - i)) .* padding);
        array = cat(2, array, Utilities.logicalToDecimal([lastBits paddingBits]));
    else
        array = cat(2, array, Utilities.logicalToDecimal(binaryArray(i:i + 7)));
    end
end

end

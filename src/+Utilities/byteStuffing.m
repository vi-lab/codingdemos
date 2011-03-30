function [ stuffedArray ] = byteStuffing( array, byteLength )
%BYTESTUFFING Summary of this function goes here
%   Detailed explanation goes here

if ~exist('byteLength', 'var')
    byteLength = 8;
end

stuffedArray = array;
len = length(stuffedArray);

for i=1:byteLength:len
    values = stuffedArray(i:i + byteLength - 1);

    if sum(values) == 8
        % Stuff in byteLength 0s
        stuffedArray = cat(2, stuffedArray(1:i + byteLength - 1), false(1, byteLength), stuffedArray(i + byteLength:end));
        len = len + byteLength;
    end
end

end

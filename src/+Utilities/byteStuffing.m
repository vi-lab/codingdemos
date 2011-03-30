function [ stuffedArray ] = byteStuffing( array, byteLength )
%BYTESTUFFING Summary of this function goes here
%   Detailed explanation goes here

if ~exist('byteLength', 'var')
    byteLength = 8;
end

stuffedArray = [];

for i=1:byteLength:length(array)
    values = array(i:i + byteLength - 1);

    stuffedArray = cat(2, stuffedArray, values);
        
    if max(values) == 1 && min(values) == 1
        % Stuff in byteLength 0s
        stuffedArray = cat(2, stuffedArray, false(1, byteLength));
    end
end

end

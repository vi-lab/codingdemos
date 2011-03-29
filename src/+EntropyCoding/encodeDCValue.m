function [ encodedLogicalBitArray ] = encodeDCValue( diffValue, huffmanTable )
%ENCODEDCVALUE Encode a single DC value using the given Huffman Code table
%   Detailed explanation goes here
diffValue
if diffValue == 0
    encodedLogicalBitArray = huffmanTable{1};
else
    % To get the category of the value we simply take the length in
    % bits needed to represent the number.
    % http://mathworld.wolfram.com/BitLength.html
    lengthInBits = ceil( log2(abs(diffValue) + 1) );
    %or
    %lengthInBits = length(dec2bin(abs(number));

    % the huffman code is followed by the bits of the magnitude value
    % Index into huffman table is length in bits + 1
    if diffValue > 0
        valueBits = Utilities.decimalToByte(diffValue);
    else
        valueBits = Utilities.decimalToByte(diffValue - 1);
    end
    valueBits
    lengthInBits
    encodedLogicalBitArray = [huffmanTable{lengthInBits + 1} valueBits(end - (lengthInBits - 1):end)];
end


end

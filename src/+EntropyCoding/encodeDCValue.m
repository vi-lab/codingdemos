function [ encodedLogicalBitArray ] = encodeDCValue( diffValue, huffmanTable )
%ENCODEDCVALUE Encode a single DC value using the given Huffman Code table
%   Detailed explanation goes here
%      
%   Note: maximum encoded value should not exceed 16 bits.

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
    if diffValue < 0
        diffValue = diffValue - 1;
    end
    
    % For DC maximum length for magnitude is 11 bits
    % Ref: CCITT Rec. T.81 (1992 E) p.89
    valueBits = Utilities.decimalToLogical(diffValue, 11); 

    % Note that the most significant bit of the appended bit sequence is 0 for
    % negative differences and 1 for positive differences.
    extraBitsForMagnitude = valueBits(end - (lengthInBits - 1):end);
    encodedLogicalBitArray = [huffmanTable{lengthInBits + 1} extraBitsForMagnitude];
end


end

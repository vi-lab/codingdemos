function [ coefficients ] = decodeACZerosRunLengthValue( RS, extraMagnitudeValue )
%UNTITLED1 Summary of this function goes here
%   Detailed explanation goes here

S_magnitudeCategory = bitand(RS, 15);
R_zerosRunLength = bitshift(RS, -4);

if R_zerosRunLength == 15
    coefficients = [zeros(1, R_zerosRunLength) 0];    
else
    value = EntropyCoding.extendSignBitOfDecodedValue( extraMagnitudeValue,  S_magnitudeCategory);
    coefficients = [zeros(1, R_zerosRunLength) value];
end

end

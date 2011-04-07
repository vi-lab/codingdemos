function [ coefficients ] = decodeACZerosRunLengthValue( RS, extraMagnitudeValue )
%UNTITLED1 Summary of this function goes here
%   Detailed explanation goes here
value = EntropyCoding.extendSignBitOfDecodedValue( extraMagnitudeValue, bitand(RS, 15) );
coefficients = [zeros(1, bitshift(RS, -4)) value];
end

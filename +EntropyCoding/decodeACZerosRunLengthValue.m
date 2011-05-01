function [ coefficients ] = decodeACZerosRunLengthValue( RS, extraMagnitudeValue )
%DECODEACZEROSRUNLENGTHVALUE Summary of this function goes here
%   Detailed explanation goes here
%
%   +EntropyCoding/decodeACZerosRunLengthValue.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   HELP INFO
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if RS == 0
    coefficients = [];
    return
end

S_magnitudeCategory = bitand(RS, 15);
R_zerosRunLength = bitshift(RS, -4);

if R_zerosRunLength == 15
    coefficients = [zeros(1, R_zerosRunLength) 0];    
else
    value = EntropyCoding.extendSignBitOfDecodedValue( extraMagnitudeValue,  S_magnitudeCategory);
    coefficients = [zeros(1, R_zerosRunLength) value];
end

end

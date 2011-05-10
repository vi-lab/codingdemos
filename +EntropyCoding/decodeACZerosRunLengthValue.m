function [ coefficients ] = decodeACZerosRunLengthValue( RS, extraMagnitudeValue )
%DECODEACZEROSRUNLENGTHVALUE Decode a JPEG RS value and magnitude bits
%
%   +EntropyCoding/decodeACZerosRunLengthValue.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Decodes a JPEG RS value and manitude bits into a coefficient.
%   JPEG RS values are 8-bit values where the top 4 bits represent the
%   zeros run-length before the coefficient and the bottom 4-bits
%   encode the magnitude Category of the coefficient value. The category
%   value is the length in bits required to represent the value. The
%   extra bits are the actual 2's compliment encoded magnitude of the
%   coefficient of the minimum required bit length.
%
%   Ref: CCITT Rec. T.81 (1992 E) p. 105-111, Section F.2.2.2
%        CCITT Rec. T.81 (1992 E) p. 89-93, Section F.1.2.2.1
%
%   Parameters -
%       RS: the (uint8) RS value for the coefficient
%       extraMagnitudeValue: the value of the extra magnitude bits (before sign extension)
%   Returns -
%       coefficients: the decoded coefficients with the zeros run
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% FIXME: Needs vectorising

if RS == 0
    coefficients = [];
    return
end

% Decode RS value into constituent parts
S_magnitudeCategory = bitand(RS, 15);
R_zerosRunLength = bitshift(RS, -4);

% A zeros run length of 15 is a special case in JPEG and represents a
% continuous run of 16 zeros. It arises when a coefficient has a
% run-length of 16 of greater zeros which cannot be encoded into the
% 4-bit field of the RS value.
if R_zerosRunLength == 15
    coefficients = [zeros(1, R_zerosRunLength) 0];
else
    % The magnitude bits must be sign extended as they are encoded in 2's
    % compliment
    value = EntropyCoding.extendSignBitOfDecodedValue( extraMagnitudeValue,  S_magnitudeCategory);
    coefficients = [zeros(1, R_zerosRunLength) value];
end

end

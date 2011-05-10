function [ stuffedArray ] = byteStuffing( array, byteLength )
%BYTESTUFFING Place a zero value byte in the bit stream after every maximum byte value
%
%   +Utilites/byteStuffing.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   The JPEG standard specifies stuffing zeros after each maximum value in
%   the entropy coded sections of the bit stream. The byte length is
%   either specified or defaults to 8 bits).
%   In JPEG a byte of plus another value is considered a marker with a
%   special meaning.
%
%   Ref: CCITT Rec. T.81 (1992 E) p.91 Section F.1.2.3
%
%   Parameters -
%       array: the input logical bit array bit stream
%   Optional Parameters -
%       byteLength: the length in bits of a 'byte', defaults to 8
%   Returns -
%       stuffedArray: the input array with necessary stuffed bytes
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% FIXME: should also support numeric array inputs

if ~exist('byteLength', 'var')
    byteLength = 8;
end

stuffedArray = array;
len = length(stuffedArray);

% TODO: Get rid of for loop, except data length grows so keep in mind
for i=1:byteLength:len
    values = stuffedArray(i:i + byteLength - 1);

    if sum(values) == 8
        % Stuff in byteLength 0s
        stuffedArray = cat(2, stuffedArray(1:i + byteLength - 1), false(1, byteLength), stuffedArray(i + byteLength:end));
        len = len + byteLength;
    end
end

end

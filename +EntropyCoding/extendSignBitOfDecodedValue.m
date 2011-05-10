function [ value ] = extendSignBitOfDecodedValue( V, T )
%EXTENDSIGNBITOFDECODEDVALUE Sign extend the given value
%
%   +EntropyCoding/extendSignBitOfDecodedValue.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   The method to perform sign extension as specified in the standard,
%   where the value V of bit length T will be in 2's compliment encoding,
%   and is an implementation of the method 'EXTEND(V,T)' in the standard
%   document.
%
%   Ref: CCITT Rec. T.81 (1992 E) p.105, F.12
%
%   Parameters -
%       V: the value prior to extension
%       T: the length of the value in bits, ie the magnitude category
%   Returns -
%       value: the resulting value after sign extension
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% FIXME: vectorise

if T == 0
    value = 0;
else
    % Top end of range
    Vt = 2^(T - 1);
    
    if V < Vt
        % Essentially sign extend the value. Must convert to a signed type.
        Vt = double(bitshift(-1, T) + 1);
        value = double(V) + Vt;
    else
        value = double(V);
    end
end

end

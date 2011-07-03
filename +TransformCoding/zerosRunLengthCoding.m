function rlcDataBlock = zerosRunLengthCoding(coeffsBlock)
%ZEROSRUNLENGTHCODING Zeros run-length code the input blocks of coefficients
%
%   +TranformCoding/zerosRunLengthCoding.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   This method perfoms the actual run-length coding for each coefficient
%   in the input block (or blocks). Since run-length pair counts will
%   vary depending on the actual coefficients in the block the ouput
%   size will vary. To prevent this (in MATLAB it is a lot faster to use
%   preallocated fixed size structures) the output is organised as a block
%   of fixed size of the maximum possible size of the run-length data, ie.
%   126 values (63 for the RS value and 63 for the actual value). Ends
%   of blocks are marked with a EOB marker, a RS value and value of zero
%   so the end of the actual encoded data in the 126 length vector is easy
%   to determine.
%   The input data is organised as vectors of 64 coefficients as output by
%   the coefficient reordering process. The input blocks are taken in
%   raster order. Thus for a 2 by 2 block image, the inpit will be a 
%   2x128 (rows x columns) matrix and the output will be a 2x252 matrix.
%
%   This method also handles the special JPEG case of zeros run-lengths of
%   larger than 15.
%
%   Ref: CCITT Rec. T.81 (1992 E) p. 89-91, Section F.1.2.2
%
%   Parameters -
%       coeffsBlock: the input block(s) of DCT coefficients
%   Returns -
%       rlcDataBlock: a block of RS values and magnitude values organised as described above
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

% input data is takes as 64 values raster order
coeffs = reshape(coeffsBlock.', 64, []).'; % now 1 row per block
rlcData = ones(size(coeffs,1), (size(coeffs,2)*2)-2);

% We use -1 padding. A count of -1 means this pair is nothing and end of
% data. We need the padding so to avoid cell arrays

% For each row
for block=1:size(coeffs, 1)
    runLengths =    -ones(1, 63);
    values =        -ones(1, 63);

    ACvalues = coeffs(block, 2:end);
    % RLE
    % find runs of zeros + magnitude , encode as value to lookup in table
    ind = find(ACvalues);
    numberOfValues = length(ind);
    % Run length is essentially the difference between the current nonzero
    % index and the previous one
    pind = [0 ind(1:end-1)];
    runLengths(1:numberOfValues) = ind - pind - 1;
    values(1:numberOfValues) = ACvalues(ind);

    if isempty(ind) || ~isempty(ind) && (ind(end) ~= length(ACvalues))
        % there is a EOB
        runLengths(numberOfValues+1)   = 0;
        values(numberOfValues+1)       = 0;
    end

    % Now must handle special JPEG standard case limiting zeros to 15 for run
    if nnz(runLengths > 15)
        overFifteens = find(runLengths > 15);
        
        % Work out how many (15,0)s are needed
        fifteensNeeded  = floor(runLengths(overFifteens) / 16);
        remainders      = rem(runLengths(overFifteens), 16);
        % Update with remainder zeros number
        runLengths(overFifteens) = remainders;
        % Insert (15,0)s
        for i=1:length(overFifteens)
            if fifteensNeeded(i)
                count = fifteensNeeded(i);
                zs = ones(1,count).*15;
                vs = zeros(1,count);
                 % insert and remove last 'count' values which will be -1s
                runLengths = [runLengths(1:overFifteens(i)-1) zs runLengths(overFifteens(i):end - count)];
                values = [values(1:overFifteens(i)-1) vs values(overFifteens(i):end - count)];
            end
        end
    end

    % Generate RS values
    % This could be optimised as a look up table
    lengthInBits = ceil( log2(abs(values) + 1) );
    RS = (runLengths .* 16) + lengthInBits;

    rlcData(block,:) = [RS values];
end

rlcDataBlock = reshape(rlcData.', [], size(coeffsBlock,1)).'; % now 1 row per block

end

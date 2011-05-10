function coefficients = coefficientOrdering( inputBlock, mode )
%COEFFICIENTORDERING Reorder coefficients according to the given mode
%
%   +TranformCoding/coefficientOrdering.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Reorder coefficients of the input block by the given mode (zig-zag by
%   default) and return a vector of order coefficients. If you wish to
%   reconstruct a block from ordered coefficients use the 'de' versions
%   of the modes. In this case inputBlock will be a vector.
%
%   Ref: CCITT Rec. T.81 (1992 E) p. 16, Figure 5
%
%   Parameters -
%       inputBlock: the input block of DCT coefficients
%       mode: the reordering mode string, 'zigzag', 'sequential', 'dezigzag', 'desequential'
%   Returns -
%       coefficients: the ordered coefficients
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if ~exist('mode', 'var')
    mode = 'zigzag';
end

switch (lower(mode))
    case 'zigzag'
        ordering = createZigZagIndices(size(inputBlock));
        coefficients = inputBlock(ordering);

    case 'sequential'
        ordering = 1:length(inputBlock(:));
        coefficients = inputBlock(ordering);

    case 'dezigzag'
        s = sqrt(length(inputBlock));
        zzordering = createZigZagIndices([s s]);
        indices = 1:length(zzordering);
        indices(zzordering) = indices;
        coefficients = reshape(inputBlock(indices), s, s);

    case 'desequential'
        s = sqrt(length(inputBlock));
        coefficients = reshape(inputBlock, s, s);
        
    otherwise
        exception = MException('CoefficientOrdering:InvalidOrderingMode', ...
                               'The mode ''%s'' is not defined as a coefficient ordering mode.', mode);
        throw(exception);
end

end

function order = createZigZagIndices(blockSize)
    % I used to have it hard coded for an 8x8 block, but the below code
    % generates the ordering for any size.
    %ordering = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];

    persistent ordering;
    
    if isempty(ordering) || numel(ordering) ~= (blockSize(1)*blockSize(2))
        % http://stackoverflow.com/questions/3024939/matrix-zigzag-reordering
        ordering = reshape(1:(blockSize(1)*blockSize(2)), blockSize);         %# indices of elements
        ordering = fliplr( spdiags( fliplr(ordering) ) );     %# get the anti-diagonals
        ordering(:,1:2:end) = flipud( ordering(:,1:2:end) );  %# reverse order of odd columns
        ordering(ordering==0) = [];                           %# keep non-zero indices
    end
    
    order = ordering;
end
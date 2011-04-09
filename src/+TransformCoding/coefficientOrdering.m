function coefficients = coefficientOrdering( inputBlock, mode )
%COEFFICIENTORDERING Summary of this function goes here
%   Detailed explanation goes here

% COMMENTS

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

function ordering = createZigZagIndices(blockSize)
    % I used to have it hard coded for an 8x8 block, but the below code
    % generates the ordering for any size.
    %ordering = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];

    % http://stackoverflow.com/questions/3024939/matrix-zigzag-reordering
    ordering = reshape(1:(blockSize(1)*blockSize(2)), blockSize);         %# indices of elements
    ordering = fliplr( spdiags( fliplr(ordering) ) );     %# get the anti-diagonals
    ordering(:,1:2:end) = flipud( ordering(:,1:2:end) );  %# reverse order of odd columns
    ordering(ordering==0) = [];                           %# keep non-zero indices
end
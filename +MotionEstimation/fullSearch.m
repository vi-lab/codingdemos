function [motionVectors predictionError] = fullSearch(inputImageMatrix, referenceFrameMatrix, blockMatching)
%FULLSEARCH Summary of this function goes here
%   Detailed explanation goes here

bs = blockMatching.blockSize;
ms = blockMatching.maximumSearchDistance;
matchFunction = blockMatching.matchFunction;

predictionError = zeros(size(inputImageMatrix));

inputW = floor(size(inputImageMatrix,2)/bs)*bs;
inputH = floor(size(inputImageMatrix,1)/bs)*bs;

motionVectors = zeros(inputW/bs, inputH/bs, 3);
%2.8s direct use of SAD, 4.7 with call to user defined function pointer, so
%half the speed :(

[X, Y] = meshgrid(1:bs:inputW, 1:bs:inputH);
[I, J] = meshgrid(1:blockMatching.maximumSearchDistance*2-1, 1:blockMatching.maximumSearchDistance*2-1);
nX = numel(X);
nI = numel(I);

for blockIndex = 1:nX
    x = X(blockIndex);
    y = Y(blockIndex);
    bx = ceil(x/bs);
    by = ceil(y/bs);
    motionVectors(bx,by,:) = [0 0 10000000];

    for refBlockIndex = 1:nI
        i = I(refBlockIndex);
        j = J(refBlockIndex);
        xref = x + (i - ms);
        yref = y + (j - ms);
        if xref < 1 || yref < 1 || xref > inputW-bs || yref > inputH-bs
            continue;
        end
        block1 = inputImageMatrix(y:y+bs-1,x:x+bs-1,:);
        block2 = referenceFrameMatrix(yref:yref+bs-1,xref:xref+bs-1,:);
        [matchError errorSurface] = matchFunction(block1, block2);
        if  matchError < motionVectors(bx,by,3)
            motionVectors(bx,by,:) = [(i - ms), (j - ms), matchError];
            predictionError(y:y+bs-1,x:x+bs-1,:) = errorSurface;
        end
    end
    % get best for this MB
    if blockMatching.verbose; disp(['Best match for MB (' num2str(bx) ',' num2str(by) ') is at (' num2str(motionVectors(bx,by,1)) ',' num2str(motionVectors(bx,by,2)) ') with error ' num2str(motionVectors(bx,by,3))]); end
end

end

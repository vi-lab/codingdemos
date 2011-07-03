function [motionVectors predictionError currentBlockData] = fullSearch(inputImageMatrix, referenceFrameMatrix, blockMatching, currentBlockIndex)
%FULLSEARCH An implementation of the full search block matching algorithm
%
%   +MotionEstimation/fullSearch.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

currentBlockData = [];
bs = blockMatching.blockSize;
ms = blockMatching.maximumSearchDistance;
matchFunction = blockMatching.matchFunction;

predictionError = zeros(size(inputImageMatrix));

inputW = floor(size(inputImageMatrix,2)/bs)*bs;
inputH = floor(size(inputImageMatrix,1)/bs)*bs;

motionVectors = zeros(inputW/bs, inputH/bs, 5);
%2.8s direct use of SAD, 4.7 with call to user defined function pointer, so
%half the speed :(

[X, Y] = meshgrid(1:bs:inputW, 1:bs:inputH);
[I, J] = meshgrid(1:blockMatching.maximumSearchDistance*2-1, 1:blockMatching.maximumSearchDistance*2-1);
nX = numel(X);
nI = numel(I);

if exist('currentBlockIndex', 'var')
    singleBlockMode = true;
else
    singleBlockMode = false;
end

if singleBlockMode
    startBI = currentBlockIndex;
    endBI = currentBlockIndex;
else
	startBI = 1;
    endBI = nX;
end


for blockIndex = startBI:endBI
    x = X(blockIndex);
    y = Y(blockIndex);
    bx = ceil(x/bs);
    by = ceil(y/bs);
    if singleBlockMode
        motionVectors(1,1,:) = [0 0 10000000 -1 -1];
    else
        motionVectors(bx,by,:) = [0 0 10000000 -1 -1];
    end
    block1 = inputImageMatrix(y:y+bs-1,x:x+bs-1,:);
    for refBlockIndex = 1:nI
        i = I(refBlockIndex);
        j = J(refBlockIndex);
        xref = x + (i - ms);
        yref = y + (j - ms);
        if xref < 1 || yref < 1 || xref > inputW-bs || yref > inputH-bs
            continue;
        end
        block2 = referenceFrameMatrix(yref:yref+bs-1,xref:xref+bs-1,:);
        [matchError errorSurface] = matchFunction(block1, block2);
        if (~singleBlockMode && (matchError < motionVectors(bx,by,3)))
            motionVectors(bx,by,:) = [(i - ms), (j - ms), matchError, x, y];
            predictionError(y:y+bs-1,x:x+bs-1,:) = errorSurface;
        elseif (singleBlockMode && (matchError < motionVectors(1,1,3)))
            motionVectors(1,1,:) = [(i - ms), (j - ms), matchError, x, y];
            predictionError(1:1+bs-1,1:1+bs-1,:) = errorSurface;
        end

        if singleBlockMode
            currentBlockData{refBlockIndex}.step = 0;
            currentBlockData{refBlockIndex}.blockx = x;
            currentBlockData{refBlockIndex}.blocky = y;
            currentBlockData{refBlockIndex}.i = i - ms;
            currentBlockData{refBlockIndex}.j = j - ms;
            currentBlockData{refBlockIndex}.xref = xref;
            currentBlockData{refBlockIndex}.yref = yref;
            currentBlockData{refBlockIndex}.matchError = matchError;
            currentBlockData{refBlockIndex}.errorSurface = errorSurface;
        end
    end
    % get best for this MB
    if blockMatching.verbose && ~singleBlockMode; 
        disp(['Best match for MB (' num2str(bx) ',' num2str(by) ') is at (' num2str(motionVectors(bx,by,1)) ',' num2str(motionVectors(bx,by,2)) ') with error ' num2str(motionVectors(bx,by,3))]); 
    end
    if blockMatching.verbose && singleBlockMode 
        disp(['Current block: ' num2str(currentBlockIndex) ' is at (' num2str(motionVectors(1,1,1)) ',' num2str(motionVectors(1,1,2)) ') with error ' num2str(motionVectors(1,1,3))]);
    end
end

end

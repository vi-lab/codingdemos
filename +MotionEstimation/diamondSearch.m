function [motionVectors predictionError] = diamondSearch(inputImageMatrix, referenceFrameMatrix, blockMatching)
%DIAMONDSEARCH Summary of this function goes here
%   Detailed explanation goes here

bs = blockMatching.blockSize;
ms = blockMatching.maximumSearchDistance;
matchFunction = blockMatching.matchFunction;

predictionError = zeros(size(inputImageMatrix));

inputW = floor(size(inputImageMatrix,2)/bs)*bs;
inputH = floor(size(inputImageMatrix,1)/bs)*bs;

motionVectors = zeros(inputW/bs, inputH/bs, 3);

[X, Y] = meshgrid(1:bs:inputW, 1:bs:inputH);
nX = numel(X);

%max search distance is 'ms'. the max/min position of the diamond center is however 'maxdiamondsize/2' 
%ie if diamond is 5,5 then center can be at most 2,2 to boundaries

%fixed diamond size 5,5, small diamons 3,3
%[I, J] = meshgrid(1:blockMatching.maximumSearchDistance*2-1, 1:blockMatching.maximumSearchDistance*2-1);
[IJb] = [0 -2; 1 -1; 2 0; 1 1; 0 2; -1 1; -2 0; -1 -1; 0 0]; % Big diamond
[IJs] = [0 -1; 1 0; 0 1; -1 0; 0 0]; % Small diamond

%nIb = numel(Ib);
%nIs = numel(Is);

for blockIndex = 1:nX
    cache = cell(inputH,inputW);
    % For this block, start diamond search at 0,0
    x = X(blockIndex);
    y = Y(blockIndex);
    bx = ceil(x/bs);
    by = ceil(y/bs);
    motionVectors(bx,by,:) = [0 0 10000000];
    block1 = inputImageMatrix(y:y+bs-1,x:x+bs-1,:);

    searchProcess = true;
    centralX = x;
    centralY = y;
    while searchProcess
        % for all big diamond blocks
        computed = false;
        errorBigStep = ones(1,size(IJb,1)).*100000;
        for refBlockIndex = 1:size(IJb,1)
            i = IJb(refBlockIndex, 1);
            j = IJb(refBlockIndex, 2);
            xref = centralX + (i);
            yref = centralY + (j);
            % Also make sure we dont go outside maximum size
            if xref < 1 || yref < 1 || xref > inputW-bs || yref > inputH-bs || abs(x - xref) > ms || abs(y - yref) > ms
                continue;
            end

            % Keep a solution cache by offset 
            if ~isempty(cache{yref, xref})
                matchError = cache{yref, xref}.error;
                errorSurface  = cache{yref, xref}.surface;
            else
                block2 = referenceFrameMatrix(yref:yref+bs-1,xref:xref+bs-1,:);
                [matchError errorSurface] = matchFunction(block1, block2);
                computed = true;
                %cache{xref, yref} = matchError;
                cache{yref, xref}.error = matchError;
                cache{yref, xref}.surface = errorSurface;
            end
            %if  matchError < motionVectors(bx,by,3)
            %    motionVectors(bx,by,:) = [(i - ms), (j - ms), matchError];
            %    predictionError(y:y+bs-1,x:x+bs-1,:) = errorSurface;
            %end
            
            errorBigStep(refBlockIndex) = matchError;
        end
        if computed
            [be bi] = min(errorBigStep);
            if ~isempty(find(bi==9,1))
                break;
            end
            % ELSE MOVE SEARCH CENTER TO best
            centralX = centralX + IJb(bi, 1);
            centralY = centralY + IJb(bi, 2);
        else
            % if all solutions are outside or already computed then stop and
            % keep best so far
            break;
        end
    end
    
    % BLOCK1 IS CURRENT POSITION xref,yref
    %block1 = inputImageMatrix(y:y+bs-1,x:x+bs-1,:);
    % for all small diamond blocks
    errorSmallStep = ones(1, size(IJs,1)).*100000;
    for refSmallBlockIndex = 1:size(IJs,1)
        i = IJs(refSmallBlockIndex, 1);
        j = IJs(refSmallBlockIndex, 2);
        xref = centralX + i;
        yref = centralY + j;
        if xref < 1 || yref < 1 || xref > inputW-bs || yref > inputH-bs
            continue;
        end
        % check if in cache
        if ~isempty(cache{yref, xref})
            matchError = cache{yref, xref}.error;
            errorSurface  = cache{yref, xref}.surface;
        else
            block2 = referenceFrameMatrix(yref:yref+bs-1,xref:xref+bs-1,:);
            [matchError errorSurface] = matchFunction(block1, block2);
            cache{yref, xref}.error = matchError;
            cache{yref, xref}.surface = errorSurface;
        end
        errorSmallStep(refSmallBlockIndex) = matchError;
        surfaceSmallStep{refSmallBlockIndex} = errorSurface;
    end
    [be bi] = min(errorSmallStep);
    % store best
    xref = centralX + IJs(bi(1), 1);
    yref = centralY + IJs(bi(1), 2);
    motionVectors(bx,by,:) = [xref-x, yref-y, be(1)];%[(i - ms), (j - ms), matchError];
    predictionError(y:y+bs-1,x:x+bs-1,:) = surfaceSmallStep{bi(1)};
    % get best for this MB
    if blockMatching.verbose; disp(['Best match for MB (' num2str(bx) ',' num2str(by) ') is at (' num2str(motionVectors(bx,by,1)) ',' num2str(motionVectors(bx,by,2)) ') with error ' num2str(motionVectors(bx,by,3))]); end
end

end

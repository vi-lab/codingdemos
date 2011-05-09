%function [ reconstruction, quiverdata ] = reconstructFrame( motionVectors, predictionErrorStruct, referenceFrameStruct, blockMatching )
function [ reconstruction ] = reconstructFrame( motionVectors, predictionErrorStruct, referenceFrameStruct, blockMatching )
%RECONSTRUCTFRAME Summary of this function goes here
%   Detailed explanation goes here
pred = double(Subsampling.subsampledToYCbCrImage(predictionErrorStruct))*2-255;
ref = double(Subsampling.subsampledToYCbCrImage(referenceFrameStruct));

recon = uint8(zeros(size(pred)));

bs = blockMatching.blockSize;

%inputW = floor(size(predictionErrorStruct,2)/bs)*bs;
%inputH = floor(size(predictionErrorStruct,1)/bs)*bs;
inputW = size(motionVectors,1)*bs;
inputH = size(motionVectors,2)*bs;

[X, Y] = meshgrid(1:bs:inputW, 1:bs:inputH);
nX = numel(X);
% x,y,u,v
%quiverdata = zeros(nX,4);

for blockIndex = 1:nX
    x = X(blockIndex);
    y = Y(blockIndex);
    bx = ceil(x/bs);
    by = ceil(y/bs);
    mv = motionVectors(bx,by,:);
    xref = x + mv(1);
    yref = y + mv(2);
    if xref < 1 || yref < 1 || xref > inputW-bs || yref > inputH-bs
        disp(['WARNING: a motion vector points outside the extent of the reference frame for block number (' num2str(bx) ',' num2str(by) ').']);
        continue;
    end
    recon(y:y+bs-1,x:x+bs-1,:) = uint8(pred(y:y+bs-1,x:x+bs-1,:) + ref(yref:yref+bs-1,xref:xref+bs-1,:));

    %quiverdata(blockIndex,:) = [x y mv(1) mv(2)];
end

reconstruction = Subsampling.ycbcrImageToSubsampled(recon);
end

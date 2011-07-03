function [ reconstruction ] = reconstructFrame( motionVectors, predictionErrorStruct, referenceFrameStruct, blockMatching )
%RECONSTRUCTFRAME Recreate a frame given a residual, motion vectors and reference frame
%
%   +MotionEstimation/reconstructFrame.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Reconstructs a frame given a residual frame structure, a referene frame
%   structure and a matrix of motion vectors for each macro block.
%
%   Parameters:
%   * motionVectors: a matrix of motion vectors where each row represents
%   a motion vector for each block in row order.
%   * predictionErrorStruct: the reference error structure
%   * referenceFrameStruct: the reference image structure
%   * blockMatching: a structure of block matching parameters
%
%   Return value:
%   * reconstruction: the reconstructed frame
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

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

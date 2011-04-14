function [ simage ] = ycbcrImageToSubsampled( image, varargin )
%YCBCRIMAGETOSUBSAMPLED Convert a ycbcr image into a subsampled struct with
%the given mode.
%
%   +Subsampling/ycbcrImageToSubsampled.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   The available modes can be obtained from Subsampling.supportedModes(). 
%   For a description on what modes mean see
%       `help Subsampling.supportedModes`
%   and the following reference.
%   Parameters:
%       'Mode': 
%   Ref: 
%       http://dougkerr.net/pumpkin/articles/Subsampling.pdf
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

interpolation = 'bilinear';
mode = '4:2:2';

for k=1:2:size(varargin,2) 
    switch lower(varargin{k})
        case 'mode'
            mode = varargin{k + 1};
        case 'interpolation'
            interpolation = varargin{k + 1};
    end
end

if size(image, 3) == 3
    c1 = image(:,:,1);
    osize = size(image);
    switch mode
        case '4:4:4' % all
            chromasize = [osize(1) osize(2)];
        case '4:4:0' % all columns, half rows
            chromasize = [floor(osize(1)/2) osize(2)];
        case '4:2:2' % all rows, half columns
            chromasize = [osize(1) floor(osize(2)/2)];
        case '4:2:0' % half rows and columns
            chromasize = [floor(osize(1)/2) floor(osize(2)/2)];
        case '4:1:1' % all rows, quarter columns
            chromasize = [osize(1) floor(osize(2)/4)];
        case '4:1:0' % half rows, quarter columns
            chromasize = [floor(osize(1)/2) floor(osize(2)/4)];
        case '4:0:0' % half rows, quarter columns
            chromasize = [floor(osize(1)/4) floor(osize(2)/4)];
    end
    
    c2 = imresize(image(:,:,2), chromasize, interpolation);
    c3 = imresize(image(:,:,3), chromasize, interpolation);
    
    simage = struct('y', c1,'cb', c2,'cr', c3,'mode', mode, 'interpolation', interpolation);
    
else 
    throw(MException('Subsample:NoColourChannels', 'This image must have 3 channels.'));
end


end

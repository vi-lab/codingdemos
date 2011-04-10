function [ ycbcrimage ] = subsampledToYCbCrImage( simage, upsampleFilter )
%SUBSAMPLEDTOYCBCRIMAGE Summary of this function goes here
%   Detailed explanation goes here

if ~exist('upsampleFilter', 'var')
    upsampleFilter = 'bilinear';
end

%   http://dougkerr.net/pumpkin/articles/Subsampling.pdf

if isfield(simage, {'y','cb','cr'})
    osize = size(simage.y);
    ycbcrimage = zeros(osize(1), osize(2), 3);
    ycbcrimage(:,:,1) = simage.y;
    ycbcrimage(:,:,2) = imresize(simage.cb, [osize(1) osize(2)], upsampleFilter);
    ycbcrimage(:,:,3) = imresize(simage.cr, [osize(1) osize(2)], upsampleFilter);
else 
    throw(MException('Subsample:NoColourChannels', 'The input image must be a struct with y, cb and cr fields corresponding to the 3 channels.'));
end

end

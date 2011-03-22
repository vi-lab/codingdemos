function [ ycbcrimage ] = s420ToImage( simage )
%S420TOIMAGE Summary of this function goes here
%   Detailed explanation goes here
%   http://dougkerr.net/pumpkin/articles/Subsampling.pdf

if isfield(simage, {'y','cb','cr'});
    osize = size(simage.y);
    ycbcrimage = zeros(osize(1), osize(2), 3);
    ycbcrimage(:,:,1) = simage.y;
    ycbcrimage(:,:,2) = imresize(simage.cb, [osize(1) osize(2)], 'bilinear');
    ycbcrimage(:,:,3) = imresize(simage.cr, [osize(1) osize(2)], 'bilinear');
else 
    throw(MException('Subsample:NoColourChannels', 'The input image must be a cell with 3 elements corresponding to the 3 channels.'));
end

end

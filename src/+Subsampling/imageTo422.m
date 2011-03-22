function [ subsampled ] = imageTo422( image )
%422 Summary of this function goes here
%   Detailed explanation goes here
%   http://dougkerr.net/pumpkin/articles/Subsampling.pdf
subsampled = cell(1,3);

if size(image, 3) == 3
    subsampled(1) = {image(:,:,1)};
    osize = size(image);
    subsampled(2) = {imresize(image(:,:,2), [osize(1) floor(osize(2)/2)], 'bilinear')};
    subsampled(3) = {imresize(image(:,:,3), [osize(1) floor(osize(2)/2)], 'bilinear')};
else 
    throw(MException('Subsample:NoColourChannels', 'This image must have 3 channels.'));
end

end

function [ subsampled ] = imageTo422( image )
%422 Summary of this function goes here
%   Detailed explanation goes here
%   http://dougkerr.net/pumpkin/articles/Subsampling.pdf

if size(image, 3) == 3
    c1 = image(:,:,1);
    osize = size(image);
    c2 = imresize(image(:,:,2), [osize(1) floor(osize(2)/2)], 'bilinear');
    c3 = imresize(image(:,:,3), [osize(1) floor(osize(2)/2)], 'bilinear');
    subsampled = struct('y',c1,'cb',c2,'cr',c3,'mode',422);
else 
    throw(MException('Subsample:NoColourChannels', 'This image must have 3 channels.'));
end

end

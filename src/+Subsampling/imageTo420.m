function [ subsampled ] = imageTo420( image )
%420 Summary of this function goes here
%   Detailed explanation goes here --
%   http://dougkerr.net/pumpkin/articles/Subsampling.pdf

if size(image, 3) == 3
    c1 = image(:,:,1);
    c2 = imresize(image(:,:,2), 0.5, 'bilinear');
    c3 = imresize(image(:,:,3), 0.5, 'bilinear');
    subsampled = struct('y',c1,'cb',c2,'cr',c3,'mode',420);
else 
    throw(MException('Subsample:NoColourChannels', 'This image must have 3 channels.'));
end

end
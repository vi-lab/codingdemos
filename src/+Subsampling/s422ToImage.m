function [ image ] = s422ToImage( imagecell )
%S422TOIMAGE Summary of this function goes here
%   Detailed explanation goes here
%   http://dougkerr.net/pumpkin/articles/Subsampling.pdf

if length(imagecell) == 3
    osize = size(imagecell{1});
    image = zeros(osize(1), osize(2), 3);
    image(:,:,1) = imagecell{1};
    image(:,:,2) = imresize(imagecell{2}, [osize(1) osize(2)], 'bilinear');
    image(:,:,3) = imresize(imagecell{3}, [osize(1) osize(2)], 'bilinear');
else 
    throw(MException('Subsample:NoColourChannels', 'The input image must be a cell with 3 elements corresponding to the 3 channels.'));
end

end

function [ simage ] = ycbcrImageToSubsampled( image, mode )
%IMAGETOSUBSAMPLED Summary of this function goes here
%   Detailed explanation goes here
%   http://dougkerr.net/pumpkin/articles/Subsampling.pdf

if ~exist('mode', 'var')
    mode = '4:2:2';
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
    end
    
    c2 = imresize(image(:,:,2), chromasize, 'bilinear');
    c3 = imresize(image(:,:,3), chromasize, 'bilinear');
    
    simage = struct('y', c1,'cb', c2,'cr', c3,'mode', mode);
    
else 
    throw(MException('Subsample:NoColourChannels', 'This image must have 3 channels.'));
end


end

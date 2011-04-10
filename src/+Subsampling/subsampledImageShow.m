function imhandle = subsampledImageShow( subsampled, parentAxes, channel, block, filter )
%S420SHOW Summary of this function goes here
%   Detailed explanation goes here

% NOTE 'block' is relative to upsampled size for subsampled channels!

if ~exist('parentAxes', 'var')
    ax = gca;
else
    ax = parentAxes;
end

if ~exist('channel', 'var')
    channel = 'all';
end

if ~exist('filter', 'var')
    filter = 'bilinear';
end


if isfield(subsampled, {'y', 'cb', 'cr'})
    if ~exist('block', 'var') || isempty(block)
        reconstructionYCbCr = uint8(Subsampling.subsampledToYCbCrImage(subsampled, filter));
    else
        subsampledBlock = subsampled;
        subsampledBlock.y = subsampledBlock.y(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1);
        subsampledBlock.cb = subsampledBlock.cb(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1);
        subsampledBlock.cr = subsampledBlock.cr(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1);
        reconstructionYCbCr = uint8(Subsampling.subsampledToYCbCrImage(subsampledBlock, filter));        
    end
    reconstructionRGB = ycbcr2rgb(reconstructionYCbCr);
elseif isfield(subsampled, {'r', 'g', 'b'})
    if ~exist('block', 'var') || isempty(block)
        reconstructionRGB = uint8(Subsampling.subsampledToRGBImage(subsampled, filter));
    else
        subsampledBlock = subsampled;
        subsampledBlock.r = subsampledBlock.r(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1);
        subsampledBlock.g = subsampledBlock.g(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1);
        subsampledBlock.b = subsampledBlock.b(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1);
        reconstructionRGB = uint8(Subsampling.subsampledToRGBImage(subsampledBlock, filter));
    end
    reconstructionYCbCr = rgb2ycbcr(reconstructionRGB);
else
    throw(MException('Subsampling:subsampledImageShow:NotValidImage', 'This image struct must have 3 channels, y, cb, cr or r, g, b.'));
end

switch channel
    case 'all'
        imhandle = imshow(reconstructionRGB, 'Parent', ax);
    case 'y'
        imhandle = imshow(reconstructionYCbCr(:,:,1), 'Parent', ax);
    case 'r'
        imhandle = imshow(reconstructionRGB(:,:,1), 'Parent', ax);
    case 'cb'
        imhandle = imshow(reconstructionYCbCr(:,:,2), 'Parent', ax);
    case 'g'
        imhandle = imshow(reconstructionRGB(:,:,2), 'Parent', ax);
    case 'cr'
        imhandle = imshow(reconstructionYCbCr(:,:,3), 'Parent', ax);
    case 'b'
        imhandle = imshow(reconstructionRGB(:,:,3), 'Parent', ax);
end

end

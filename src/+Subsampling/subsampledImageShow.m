function imhandle = subsampledImageShow( subsampled, parentAxes, block )
%S420SHOW Summary of this function goes here
%   Detailed explanation goes here

if ~exist('parentAxes', 'var')
    ax = gca;
else
    ax = parentAxes;
end

if isfield(subsampled, {'y', 'cb', 'cr'})
    if ~exist('block', 'var')
        imhandle = imshow(ycbcr2rgb(uint8(Subsampling.subsampledToYCbCrImage(subsampled))), 'Parent', ax);
    else
        subsampledBlock = subsampled;
        subsampledBlock.y = subsampledBlock.y(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1);
        subsampledBlock.cb = subsampledBlock.cb(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1);
        subsampledBlock.cr = subsampledBlock.cr(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1);
        imhandle = imshow(ycbcr2rgb(uint8(Subsampling.subsampledToYCbCrImage(subsampledBlock))), 'Parent', ax);
    end
elseif isfield(subsampled, {'r', 'g', 'b'})
    if ~exist('block', 'var')
        imhandle = imshow(uint8(Subsampling.subsampledToRGBImage(subsampled)), 'Parent', ax);
    else
        subsampledBlock = subsampled;
        subsampledBlock.r = subsampledBlock.r(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1);
        subsampledBlock.g = subsampledBlock.g(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1);
        subsampledBlock.b = subsampledBlock.b(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1);
        imhandle = imshow(uint8(Subsampling.subsampledToRGBImage(subsampledBlock)), 'Parent', ax);
    end
else
    throw(MException('Subsampling:subsampledImageShow:NotValidImage', 'This image struct must have 3 channels, y, cb, cr or r, g, b.'));
end

end

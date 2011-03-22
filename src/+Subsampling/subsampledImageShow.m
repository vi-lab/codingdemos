function subsampledImageShow( subsampled )
%S420SHOW Summary of this function goes here
%   Detailed explanation goes here

if isfield(subsampled, {'y', 'cb', 'cr'})
    imshow(ycbcr2rgb(uint8(Subsampling.subsampledToYCbCrImage(subsampled))), 'Parent', gca);
elseif isfield(subsampled, {'r', 'g', 'b'})
    imshow(uint8(Subsampling.subsampledToRGBImage(subsampled)), 'Parent', gca);
else
    throw(MException('Subsampling:subsampledImageShow:NotValidImage', 'This image struct must have 3 channels, y, cb, cr or r, g, b.'));
end

end

function imhandle = subsampledImageShow( subsampled, varargin )
%subsampledImageShow Display the given subsampled image on the current or
%given axes.
%   This function draws the given subsampled image struct on to the current
%   or given 'parentAxes'. 
%   Optional Parameters: 
%       'Parent' : axes object to draw the object on to.
%       'Channel' : The colour channel to draw, e.g. 'y' or 'cb'
%       'Block' : A vector [x_position y_position width height] describing
%       a subblock of the image to draw. Note that these are relative to
%       upsampled size for subsampled channels!
%       'Interpolation' : The interpolation mode as described by 'imresize'

% Default values.
filter = 'bilinear';
channel = 'all';
ax = gca;
colourDisplay = false;

for k=1:2:size(varargin,2) 
    switch lower(varargin{k})
        case 'parent'
            ax = varargin{k + 1};
        case 'channel'
            channel = varargin{k + 1};
        case 'block'
            block = varargin{k + 1};
        case 'interpolation'
            filter = varargin{k + 1};
        case 'colourdisplay' 
            colourDisplay = varargin{k + 1};
    end
end

%If image is a YCbCr
if isfield(subsampled, {'y', 'cb', 'cr'})
    reconstructionYCbCr = uint8(Subsampling.subsampledToYCbCrImage(subsampled, filter));
    if exist('block', 'var') && ~isempty(block)
        reconstructionYCbCr = reconstructionYCbCr(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1,:);
    end
    reconstructionRGB = ycbcr2rgb(reconstructionYCbCr);
%If Image is RGB
elseif isfield(subsampled, {'r', 'g', 'b'})
    reconstructionRGB = uint8(Subsampling.subsampledToRGBImage(subsampled, filter));
    if exist('block', 'var') && ~isempty(block)
        reconstructionRGB = reconstructionRGB(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1,:);
    end
    reconstructionYCbCr = rgb2ycbcr(reconstructionRGB);
else
    throw(MException('Subsampling:subsampledImageShow:NotValidImage', 'This image struct must have 3 channels, y, cb, cr or r, g, b.'));
end

% TODO: this is somewhat inefficient as we must process each channel even
% when we only want one channel. Improve.
switch channel
    case 'all'
        imhandle = imshow(reconstructionRGB, 'Parent', ax);
    case 'y'
        imhandle = imshow(reconstructionYCbCr(:,:,1), 'Parent', ax);
    case 'r'
        imhandle = imshow(reconstructionRGB(:,:,1), 'Parent', ax);
    case 'cb'
        if colourDisplay
            imToDisplay = uint8(ones(size(reconstructionYCbCr)).*128);
            imToDisplay(:,:,2) = reconstructionYCbCr(:,:,2);
            imhandle = imshow(ycbcr2rgb(imToDisplay), 'Parent', ax);
        else
            imhandle = imshow(reconstructionYCbCr(:,:,2), 'Parent', ax);
        end
    case 'g'
        imhandle = imshow(reconstructionRGB(:,:,2), 'Parent', ax);
    case 'cr'
        if colourDisplay
            imToDisplay = uint8(ones(size(reconstructionYCbCr)).*128);
            imToDisplay(:,:,3) = reconstructionYCbCr(:,:,3);
            imhandle = imshow(ycbcr2rgb(imToDisplay), 'Parent', ax);
        else
            imhandle = imshow(reconstructionYCbCr(:,:,3), 'Parent', ax);
        end
    case 'b'
        imhandle = imshow(reconstructionRGB(:,:,3), 'Parent', ax);
end

end

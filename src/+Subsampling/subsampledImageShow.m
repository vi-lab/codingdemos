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
%       'Upsample' : If false the channel is not resized. (only valid with
%       Channel, also if false ColourDisplay is ignored)
%       'ColourDisplay' : Show channel as colour image instead of greyscale

% Default values.
filter = 'bilinear';
channel = 'all';
ax = gca;
colourDisplay = false;
upsample = true;

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
        case 'upsample'
            upsample = varargin{k + 1};
    end
end

%If image is a YCbCr
if isfield(subsampled, {'y', 'cb', 'cr'}) 
    if upsample
        reconstructionYCbCr = uint8(Subsampling.subsampledToYCbCrImage(subsampled, filter));
        if exist('block', 'var') && ~isempty(block)
            reconstructionYCbCr = reconstructionYCbCr(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1,:);
        end
        reconstructionRGB = ycbcr2rgb(reconstructionYCbCr);
    else
        reconstructionYCbCr = uint8(subsampled.(channel));
        if exist('block', 'var') && ~isempty(block)        
            % downsample block dims
            rd = size(subsampled.y, 1) / size(reconstructionYCbCr, 1);
            cd = size(subsampled.y, 2) / size(reconstructionYCbCr, 2);
            block = [(block(1)/cd) (block(2)/rd) (block(3)/cd) (block(4)/rd)];
            reconstructionYCbCr = reconstructionYCbCr(block(2):block(2)+block(4)-1, block(1):block(1)+block(3)-1,:);
        end
    end
else
    throw(MException('Subsampling:subsampledImageShow:NotValidImage', 'This image struct must have 3 channels, y, cb, cr.'));
end

% TODO: this is somewhat inefficient as we must process each channel even
% when we only want one channel. Improve.
switch channel
    case 'all'
        if size(reconstructionRGB, 3) == 3
            imhandle = imshow(reconstructionRGB, 'Parent', ax);
        else
            throw(MException('Subsampling:subsampledImageShow:InvalidParameters', 'It is not possible to display all channels is ''Upsample'' is false as the image cannot be reconstructed.'));
        end
    case 'y'
        imhandle = imshow(reconstructionYCbCr(:,:,1), 'Parent', ax);
    case 'cb'
        if upsample
            chanData = reconstructionYCbCr(:,:,2);
        else
            chanData = reconstructionYCbCr;
        end
        if colourDisplay
            imToDisplay = uint8(ones(size(reconstructionYCbCr,1), size(reconstructionYCbCr,2), 3).*128);
            imToDisplay(:,:,2) = chanData;
            chanData = ycbcr2rgb(imToDisplay);
        end
        if ~upsample
            chanData = fillInImage(chanData, size(subsampled.y));
        end
        imhandle = imshow(chanData, 'Parent', ax);
    case 'cr'
        if upsample
            chanData = reconstructionYCbCr(:,:,3);
        else
            chanData = reconstructionYCbCr;
        end
        if colourDisplay
            imToDisplay = uint8(ones(size(reconstructionYCbCr,1), size(reconstructionYCbCr,2), 3).*128);
            imToDisplay(:,:,3) = chanData;
            chanData = ycbcr2rgb(imToDisplay);
        end
        if ~upsample
            chanData = fillInImage(chanData, size(subsampled.y));
        end
        imhandle = imshow(chanData, 'Parent', ax);
end

end

function chanData = fillInImage(channel, szY)
    [r c d] = size(channel);
    chanData = horzcat(channel, (ones(r, szY(2)-c, d).*204));
    chanData = vertcat(chanData, (ones(szY(1)-r, szY(2), d).*204));
end

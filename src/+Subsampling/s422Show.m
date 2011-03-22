function s422Show( s422 )
%S420SHOW Summary of this function goes here
%   Detailed explanation goes here

imshow(ycbcr2rgb(uint8(Subsampling.s422ToImage(s422))), 'Parent', gca);

end

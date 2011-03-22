function s420Show( s420 )
%S420SHOW Summary of this function goes here
%   Detailed explanation goes here

imshow(ycbcr2rgb(uint8(Subsampling.s420ToImage(s420))), 'Parent', gca);

end

classdef VideoEncoder < GUIs.base
%VIDEOENCODER Summary of this class goes here
%   Detailed explanation goes here

   properties
       videoEncoder
   end

   methods
       function obj = VideoEncoder()
            obj = obj@GUIs.base('VideoEncoder');
            
            videoEncoder = Video.encoder('examples/imseq/vid:0000:0003:.jpg');
            videoEncoder.encode('gop', 'ip', 'verbose', true, 'Quality', 80, 'BlockMatchingSearchDistance', 8, 'BlockMatching', 'DSA');
        end
   end
end 

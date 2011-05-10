function scaledQuantisationTable = qualityFactorToQuantisationTable(quantisationTable, qualityFactor)
%QUALITYFACTORTOQUANTISATIONTABLE Scale a DCT quantisation table by a quality factor between 0 and 100
%
%   +TranformCoding/qualityFactorToQuantisationTable.m
%   Part of 'MATLAB Image & Video Compression Demos'
%
%   Convert a quality factor (between 0 and 100) and start quantisation
%   table into a scaled quantisation table as per the IJG's JPEG
%   implementation.
%
%   Ref: http://libjpeg.cvs.sourceforge.net/viewvc/libjpeg/libjpeg/
%
%   Parameters -
%       quantisationTable: the starting quantisation table (e.g. from the JPEG standard)
%       qualityFactor: the quality factor
%   Returns -
%       scaledQuantisationTable: the scaled quantisation table
%
%   Licensed under the 3-clause BSD license, see 'License.m'
%   Copyright (c) 2011, Stephen Ierodiaconou, University of Bristol.
%   All rights reserved.

if( qualityFactor < 1 )
    qualityFactor = 1;
elseif( qualityFactor > 100 )
    qualityFactor = 100;
end
if (qualityFactor < 50)
    scaleFactor = 5000 / qualityFactor;
else
    scaleFactor = 200 - qualityFactor*2;
end
% set quantisation tables
scaledQuantisationTable = round(((quantisationTable .* scaleFactor) + 50) ./ 100);
% limit the values to the valid range 
scaledQuantisationTable( scaledQuantisationTable <= 0 ) = 1;
scaledQuantisationTable( scaledQuantisationTable > 255 ) = 255;

return
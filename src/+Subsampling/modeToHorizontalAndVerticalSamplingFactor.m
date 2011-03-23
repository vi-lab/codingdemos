function [ Hi Vi ] = modeToHorizontalAndVerticalSamplingFactor( mode )
%MODETOHORIZONTALANDVERTICALSAMPLINGFACTOR Summary of this function goes here
%   Detailed explanation goes here
switch mode
    case '4:4:4' % all
        Hi = 1; Vi = 1;
    case '4:4:0' % all columns, half rows
        Hi = 1; Vi = 2;
    case '4:2:2' % all rows, half columns
        Hi = 2; Vi = 1;
    case '4:2:0' % half rows and columns
        Hi = 2; Vi = 2;
    case '4:1:1' % all rows, quarter columns
        Hi = 4; Vi = 1;
    case '4:1:0' % half rows, quarter columns
        Hi = 4; Vi = 2;
end

end

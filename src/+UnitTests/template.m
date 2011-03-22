function [ success ] = template( input_args )
%TEMPLATE Summary of this function goes here
%   Detailed explanation goes here


try 
    % test code
    
    success = true;
catch ME
    disp('*** Unit Test Failure: ***');
    disp(mfilename('fullpath'));
    disp(ME.message);
    success = false;
end

end

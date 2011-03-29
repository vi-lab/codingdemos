function [ success ] = binaryConversions( input_args )
%BINARYCONVERSIONS Summary of this function goes here
%   Detailed explanation goes here

try 
    % test code
    % 2's compliment
    if ~Utilities.decimalToTwosComplimentDecimal(-2, 6) == 62
        throw(MException('unittest:binaryConversions','decimalToTwosComplimentDecimal 1 failed'));
    end
    try
        Utilities.decimalToTwosComplimentDecimal(1,3);
        throw(MException('unittest:binaryConversions','decimalToTwosComplimentDecimal 2 failed'));
    catch e
    end
    try
        Utilities.decimalToTwosComplimentDecimal(-100, 4);
        throw(MException('unittest:binaryConversions','decimalToTwosComplimentDecimal 3 failed'));
    catch e
    end
    
	% decimal To Byte
    if ~isequal(logical([0 1 1 1 1 0]), Utilities.decimalToBinary(30, 6))
        throw(MException('unittest:binaryConversions','decimalToBinary 1 failed'));
    end
    try
        Utilities.decimalToBinary(1001,3);
        throw(MException('unittest:binaryConversions','decimalToBinary 2 failed'));
    catch e
    end
    if ~isequal(logical([1 1 1 0]), Utilities.decimalToBinary(-2, 4))
        throw(MException('unittest:binaryConversions','decimalToBinary 3 failed'));
    end
    
    if ~isequal(logical([0 1 1 1 1 0 1 1]), Utilities.decimalToByte(123))
        throw(MException('unittest:binaryConversions','decimalToByte 1 failed'));
    end
    try
        Utilities.decimalToByte(1001);
        throw(MException('unittest:binaryConversions','decimalToByte 2 failed'));
    catch e
    end
    if ~isequal(logical([1 1 1 1 1 1 1 1]), Utilities.decimalToByte(-1))
        throw(MException('unittest:binaryConversions','decimalToByte 3 failed'));
    end
     
    if ~isequal(logical([0 0 0 0 0 0 1 1 1 1 1 0 1 0 0 1]), Utilities.decimalToShort(1001))
        throw(MException('unittest:binaryConversions','decimalToShort 1 failed'));
    end
    try
        Utilities.decimalToShort(1001124);
        throw(MException('unittest:binaryConversions','decimalToShort 2 failed'));
    catch e
    end
    if ~isequal(logical([1 1 1 1 1 0 1 1 0 0 1 0 0 1 0 1]), Utilities.decimalToShort(-1243))
        throw(MException('unittest:binaryConversions','decimalToShort 1 failed'));
    end

    
    if ~Utilities.logicalToUnsignedDecimal([1 0 1 1 1 1 0 0 0]) == 376
        throw(MException('unittest:binaryConversions','logicalToUnsignedDecimal 1 failed'));
    end
    if ~Utilities.logicalToUnsignedDecimal([1 0 1 0 1 1 1 1 1 1 1 1 1 1 1]) == 22527
        throw(MException('unittest:binaryConversions','logicalToUnsignedDecimal 1 failed'));
    end
    
    if ~Utilities.logicalToSignedDecimal([1 0 1 1 1 1 0 0 0]) == -136
        throw(MException('unittest:binaryConversions','logicalToSignedDecimal 1 failed'));
    end
    if ~Utilities.logicalToSignedDecimal([1 0 1 0 1 1 1 1 1 1 1 1 1 1 1]) == -10241
        throw(MException('unittest:binaryConversions','logicalToSignedDecimal 1 failed'));
    end

    
    
    if ~isequal([255 1 15], Utilities.logicalArrayToUnsignedNumericArray( [1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 1 0 0 0 0], 1))
        throw(MException('unittest:binaryConversions','logicalArrayToUnsignedNumericArray 1 failed'));
    end
    if ~isequal([10 171 129], Utilities.logicalArrayToUnsignedNumericArray(logical([0 0 0 0 1 0 1 0 1 0 1 0 1 0 1 1 1 0 0 0 0 0 0])))
        throw(MException('unittest:binaryConversions','logicalArrayToUnsignedNumericArray 1 failed'));
    end
    if ~isequal([-1 1 -113], Utilities.logicalArrayToSignedNumericArray( [1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 0 0 0], 1))
        throw(MException('unittest:binaryConversions','logicalArrayToSignedNumericArray 1 failed'));
    end

    if ~isequal(logical([1 1 1 1 0 0 1 1]), Utilities.hexToByte('F3'))
        throw(MException('unittest:binaryConversions','hexToByte 1 failed'));
    end
    if ~isequal(logical([1 1 1 0 0 0 1 1 1 1 0 1 1 0 1 0]), Utilities.hexToShort('E3DA'))
        throw(MException('unittest:binaryConversions','hexToShort 1 failed'));
    end
    
    if ~isequal(logical([1 0 1 0 0 0 0 1]), Utilities.decimalNibblesToByte(10, 1))
        throw(MException('unittest:binaryConversions','decimalNibblesToByte 1 failed'));
    end
    try
        Utilities.decimalNibblesToByte(10, -1);
        throw(MException('unittest:binaryConversions','decimalNibblesToByte 2 failed'));
    catch e
    end
    
    if ~isequal(logical([1 0 1 0 1 0 1 1]), Utilities.hexNibblesToByte('A', 'B'))
        throw(MException('unittest:binaryConversions','hexNibblesToByte 1 failed'));
    end
    if Utilities.logicalToUnsignedDecimal(logical([1 0 1 0 1 0 1 1])) ~= 171
        throw(MException('unittest:binaryConversions','logicalToDecimal 1 failed'));
    end

    
    success = true;
catch ME
    disp('*** Unit Test Failure: ***');
    disp(mfilename('fullpath'));
    disp(ME.identifier);
    disp(ME.message);
    disp(ME.stack);
    success = false;
end


end

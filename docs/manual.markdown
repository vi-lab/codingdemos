Image and Video Compression Teaching Tool Help
----------------------------------------------
Copyright (c) University of Bristol 2011

Introduction
------------

This tool 

Requirements
------------
* A computer with at least 2GB RAM, preferably a Core Duo 2.6GHz or faster
* MATLAB R2008a or newer (note you may see deprecation warnings in future versions)
* The Image and Video Processing toolbox from Mathworks


Getting Started
---------------


The Screens
-----------

## The Toolbar

### Panning and Zooming

## Screen 1: Redundancy

## Screen 2: 

## Screen 2: 

## Screen 2: 

## Screen 2: 

Adding Example Images
---------------------

Learning More
-------------

The source code is organised into packages of code according to
functionality. The methods in each package are documented with description,
usage and references to documents with more information. To view help on a
specific method either open the file in a text editor or use the `help`
MATLAB command, e.g. `help JPEG.encoder`.

Available Methods
-----------------

Available methods in each package.

* EntropyCoding:    ChromaACHuffmanCodeCountPerCodeLength
                    ChromaACHuffmanSymbolValuesPerCode
                    ChromaDCHuffmanCodeCountPerCodeLength
                    ChromaDCHuffmanSymbolValuesPerCode
                    decodeACZerosRunLengthValue
                    decodeValue
                    encodeACZerosRunLengthValue
                    encodeDCValues
                    extendSignBitOfDecodedValue
                    generateDecodingProcedureTable
                    generateEncodingProcedureCodeTables
                    generateHuffmanCodeLengthAndSymbolTablesFromData
                    generateTableOfHuffmanCodes
                    generateTableOfHuffmanCodeSizes
                    getValueBetweenBitsFromNumericArray
                    LuminanceACHuffmanCodeCountPerCodeLength
                    LuminanceACHuffmanSymbolValuesPerCode
                    LuminanceDCHuffmanCodeCountPerCodeLength
                    LuminanceDCHuffmanSymbolValuesPerCode

* JPEG:             encoder
                    decoder

* MotionEstimation: createMotionVectorsAndPredictionError
                    diamondSearch
                    fullSearch
                    meanOfAbsoluteDifference
                    meanOfSquaredDifference
                    reconstructFrame
                    sumOfAbsoluteDifference
                    sumOfSquaredDifference

* Subsampling:      horizontalAndVerticalSamplingFactorsToMode
                    modeToHorizontalAndVerticalSamplingFactors
                    subsampledImageShow
                    subsampledToYCbCrImage
                    supportedModes
                    ycbcrImageToSubsampled

* TransformCoding:  chromaQuantisationTable
                    coefficientOrdering
                    createBasisImage
                    dequantisationWithTable
                    differentiallyCodeDC
                    luminanceQuantisationTable
                    qualityFactorToQuantisationTable
                    quantisationWithTable
                    zerosRunLengthCoding

* Utilities:        byteStuffing
                    decimalNibblesToByte
                    decimalToByte
                    decimalToLogical
                    decimalToShort
                    decimalToTwosComplimentDecimal
                    hexNibblesToByte
                    hexToByte
                    hexToShort
                    logicalArrayToSignedNumericArray
                    logicalArrayToUnsignedNumericArray
                    logicalToSignedDecimal
                    logicalToUnsignedDecimal
                    padLogicalArray
                    padNumericArray
                    peakSignalToNoiseRatio
                    readBinaryFileToArray
                    unsignedDecimalToByteWithLookupTable
                    unsignedNumericArrayToLogicalArray
                    writeBinaryFileFromArray

* Video:            encoder
                    decoder

Misc
----

To convert between videos and image sequences use FFMPEG. There is an
excellent guide [here](http://www.catswhocode.com/blog/19-ffmpeg-commands-for-all-needs).

References
----------


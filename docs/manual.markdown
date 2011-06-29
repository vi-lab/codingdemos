
Image and Video Compression Teaching Tool Help
----------------------------------------------

Copyright 2011 (c) University of Bristol. 

See License.m for the project code license.

Developed at the [Bristol University Visual Information Laboratory](http://www.bris.ac.uk/vi-lab/)

(Compile this document to HTML with `perl Markdown/Markdown.pl manual.markdown > manual.html`)

- - -

Introduction
------------

The aim of this software is to act as a demonstration and teaching aid for
courses in Image and Video Compression. The tool demonstrates principles such
as spatial and temporal redundancy, colour channel subsampling, JPEG image
compression, DCT transform coding, simple motion compensated video compression
and motion estimation block matching.

Targeted at demonstrating to University and high-school level students, but
useful for MSc/PhD level students for code components.

Requirements
------------
* A computer with at least 2GB RAM, preferably a Core Duo 2.6GHz or faster
* MATLAB R2008a or newer (note you may see deprecation warnings in future versions)
* The Image and Video Processing toolbox from Mathworks


Getting Started
---------------

Begin the home demo screen with the command `start` in the root directory
of the project. To navigate between demos use the Home/Back and Forward
arrows in the screen toolbar. To show or hide more detailed elements of the
demos screens use the Advanced Mode button (the green plus button).

- - -

The Screens
-----------

### The Toolbar

The main toolbar, located at the top of each screen, provides some common
functionality. This includes:

* _Navigation_: The first 3 buttons allow navigation of the demo screens. The
  `Home` button with the small house icon will move the user to the 1st demo
  screen. The Left and Right arrow buttons will move the user between the demo
  screens sequentially.
* _Advanced Mode_: If available a button with a green (+) icon enables an
  advanced mode for the screen. This results in the display of more on screen
  controls to allow further options to be configured for the given demo.
* _Panning and Zooming_: The zoom and pan buttons with a magnifying glass and
  mouse icon respectively are toggle buttons. Clicking them will enable/disable
  the respective mode. These modes are to allow the user to zoom and pan any
  axes (images/figures) on the demo screen. For some screens the figures in a
  particular demo are linked, meaning pan or zooming one will perform the same
  operation on any linked figures. 


### Screen 1: Redundancy

### Screen 2: 

### Screen 3: 

### Screen 4: 

### Screen 5: 

Adding Example Images
---------------------

Learning More
-------------

The source code is organised into packages of code according to
functionality. The methods in each package are documented with description,
usage and references to documents with more information. To view help on a
specific method either open the file in a text editor or use the `help`
MATLAB command, e.g. `help JPEG.encoder`.

- - -

Available Packages
------------------

The following packages are included:

* GUIs: Contains the classes that implement the user interface screens. The
  `base` class contains any shared functionality and all screens should
  derive from this (and chain the parent constructor).
* Subsampling: Contains methods that implement functionality related to
  chroma subsampling and reconstruction.
* TransformCoding: Contains methods performing stages of the DCT process.
* EntropyCoding: Contains methods for the entropy encoding/decoding of JPEG
  (Huffman coding).
* JPEG: Contains the JPEG encoder and decoder bodies.
* Video: A motion compensated video coder, using JPEG for intraframe coding.
* MotionEstimation: The motion estimation functionality, such as difference
  calculation, block matching (full and diamond search).
* Utilities: Contains helper methods, such as methods to convert logical
  arrays of bits into numerical values and vice-versa.
* ThirdParty: 3rd party code, such as a faster implementation of the DCT.
* UnitTests: Unit tests for all packages.

Available Methods
-----------------

Available methods in each package.

* EntropyCoding:
    - ChromaACHuffmanCodeCountPerCodeLength
    - ChromaACHuffmanSymbolValuesPerCode
    - ChromaDCHuffmanCodeCountPerCodeLength
    - ChromaDCHuffmanSymbolValuesPerCode
    - decodeACZerosRunLengthValue
    - decodeValue
    - encodeACZerosRunLengthValue
    - encodeDCValues
    - extendSignBitOfDecodedValue
    - generateDecodingProcedureTable
    - generateEncodingProcedureCodeTables
    - generateHuffmanCodeLengthAndSymbolTablesFromData
    - generateTableOfHuffmanCodes
    - generateTableOfHuffmanCodeSizes
    - getValueBetweenBitsFromNumericArray
    - LuminanceACHuffmanCodeCountPerCodeLength
    - LuminanceACHuffmanSymbolValuesPerCode
    - LuminanceDCHuffmanCodeCountPerCodeLength
    - LuminanceDCHuffmanSymbolValuesPerCode

* JPEG:             
    - encoder
    - decoder

* MotionEstimation: 
    - createMotionVectorsAndPredictionError
    - diamondSearch
    - fullSearch
    - meanOfAbsoluteDifference
    - meanOfSquaredDifference
    - reconstructFrame
    - sumOfAbsoluteDifference
    - sumOfSquaredDifference

* Subsampling:      
    - horizontalAndVerticalSamplingFactorsToMode
    - modeToHorizontalAndVerticalSamplingFactors
    - subsampledImageShow
    - subsampledToYCbCrImage
    - supportedModes
    - ycbcrImageToSubsampled

* TransformCoding:  
    - chromaQuantisationTable
    - coefficientOrdering
    - createBasisImage
    - dequantisationWithTable
    - differentiallyCodeDC
    - luminanceQuantisationTable
    - qualityFactorToQuantisationTable
    - quantisationWithTable
    - zerosRunLengthCoding

* Utilities:        
    - byteStuffing
    - decimalNibblesToByte
    - decimalToByte
    - decimalToLogical
    - decimalToShort
    - decimalToTwosComplimentDecimal
    - hexNibblesToByte
    - hexToByte
    - hexToShort
    - logicalArrayToSignedNumericArray
    - logicalArrayToUnsignedNumericArray
    - logicalToSignedDecimal
    - logicalToUnsignedDecimal
    - padLogicalArray
    - padNumericArray
    - peakSignalToNoiseRatio
    - readBinaryFileToArray
    - unsignedDecimalToByteWithLookupTable
    - unsignedNumericArrayToLogicalArray
    - writeBinaryFileFromArray

* Video:            
    - encoder
    - decoder

Misc
----

To convert between videos and image sequences use FFMPEG. There is an
excellent guide [here](http://www.catswhocode.com/blog/19-ffmpeg-commands-for-all-needs).

References
----------


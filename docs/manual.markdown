
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

### Getting Started
Begin the home demo screen with the command `start` in the root directory
of the project. To navigate between demos use the Home/Back and Forward
arrows in the screen toolbar. To show or hide more detailed elements of the
demos screens use the Advanced Mode button (the green plus button).

### Important Note
For some demo screens the 1st time they are run a setup time is required.
For example for the Video Encoding screen a cache of processed frames is
created on first startup to speed up subsequent loads. Therefore for the
purpose of demonstrations you should run the demos prior to using them live.
The files created are stored in the root program folder and have a `.mat`
extension. Once these have been created they can be taken with the program to
other machines to be used there too.

### Requirements
* A computer with at least 2GB RAM, preferably a Core Duo 2.6GHz or faster
* MATLAB R2008a or newer (note you may see deprecation warnings in future versions)
* The Image and Video Processing toolbox from Mathworks

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


### Screen 1: Redundancy - Spatial and Temporal Correlation

Demonstrates spatial and temporal correlation. The top half of the screen shows
the row autocorrelation for the currently selected row of the input image. A
row can be selected by clicking on the input image axes. A random image can be
generated using the `Random Image` button. The number of lags for the 
autocorrelation plot is set by default to 10 lags, however this can be changed
via a slider in the top right of the screen which is enabled with the Advanced
Mode of the screen.

The bottom half demonstrates temporal correlation. The demonstration video is
fixed. A random sequence of frames can be generated using the `Random Video`
button. The correlation plot shows the correlation between a selected pixel in
the first frame and subsequent frames in the sequence. A target pixel can be
selected by clicking on the image axes. Use the `Play` button to automatically
play back the video frames, or use the `Step` button to single step each frame
and watch the plot evolve.

### Screen 2: Colour Channel Perceptual Redundancy (Subsampling)

This demo shows the perceptual redundancy associated with colour in images. The
input image is selected from the input image combo box and shows the given
image in each axes with the subsampling mode show below each respectively.
Changing the subsampling mode for a given axes updates the displayed image
automatically. To display each channel individually use the top middle combobox
and choose between the intensity channel or the Cb/Cr channels. When selecting
a colour channel the check box above this combo box becomes enabled and on
selection displays the channel in the opposing colours it represents.

If a colour channel is on display the check box at the bottom of each image
axis called `Show upsampled` will become enabled. When unchecked the colour
channel will be show in its subsampled size, if checked the channel will be
shown upsampled to the original image size.

If Advanced mode is enabled a combo box in the top right is shown which gives
the user the option of the type of interpolation filter to use when upsampling
the colour channels. Advanced mode also enables a display at the bottom of each
axes which show the selected block of 4x2 pixels (select a block on any image
with a mouse click). The top left block shows the actual block pixels, the top
right shows the subsampling structure for the given mode, the bottom left image
shows the Cb channel for the current mode and the bottom right the Cr channel.

### Screen 3: JPEG Image Compression

The screen demonstrates a top level view of JPEG image compression. An input
image is selected and passes through a full MATLAB implementation of a JPEG
encoder and decoder. The JPEG Quality factor is set by the slider in top left.
While coding is occurring the slider greys out. When complete the resulting
images are displayed with statistics on compression and PSNR.

Note due to the slightly slow implementation of our JPEG encoder and decoder in
MATLAB if changing the input image or the JPEG quality factor there will be a
delay of a few seconds. The application then caches the result. Note however
that the more the cached results the longer the startup time for the demo,
hence it might be wise to clear the cache by removing the `JPEGcache.mat`
occasionally.

### Screen 4: Transform Coding with the DCT

After selecting an input image the input and output from the transform coding
process are shown in the left and right image axes. In the centre of the frame
a grid shows images of the DCT bases arranged so that top left is the DC
coefficient and the bottom right the highest frequency component in both the
horizontal and vertical directions. Click on a basis to disable that
coefficient. Use the `Set All` and `Remove All` buttons to perform these
actions accordingly. At each basis click the output image will update.

Note `disabling` a DCT basis effectively zeros that coefficient in the inverse
transform.

The JPEG quality slider sets the quantisation parameter for the coding process.
The slider goes grey while the output is being updated.

The tables of numbers in the bottom half of the screen show the pixels,
coefficients, quantised coefficients, dequantised and inverse transformed
coefficients and final output pixels of the currently selected 8x8 pixel block.

To select a block simply click on the input image axes. A rectangle will display
the location of the selected block.

### Screen 5: Motion Compensated Video Encoder

This demo displays the outputs from a number of stages of a generic video
encoder. The input video sequence is selected from a set of fixed options in
the top left. Playback is started or paused using the `Play` toggle button. If
playback is paused then the input can be stepped forward at a single frame at a
time using the `Step 1 Frame` button. The top left checkbox `Loop Video?` if
enabled allows video playback to loop. 

The checkbox in the top middle of the screen enables the display of the
residual frames, both before and after coding. Due to a quirk of the layering
of MATLAB when enabled the text in the diagram is disabled.

To view a particular output in larger size simply click on the desired output.
The first click will slightly expand the size of the output and the second
click will expand the output to fullscreen. A third click restores the view to
its original size.

The output graph has a drop down selection box underneath which allows the user
to choose the output statistic to display. To see the output graph update after
changing the video must be playing, or stepped forward one frame.

Note the start time for this screen can be significant as the video cache is
loaded. Also note that if it is the 1st time this demo is being run a cache of
results may need to be created resulting in a long startup. You can see the
progress of this in the MATLAB console.

### Screen 6: Block Matching for Motion Compensation

desc


Adding Example Images
---------------------

Screens 1, 2, 3 and 4 all use input images from the directory `examples/`
located in the root program directory. Any JPEG, PNG or BMP images located in
this folder will appear in the drop down selection boxes in these demos. To add
simply add new images to this folder and restart the demo screens. Note: the
images should not be too large as this will cause a very large memory
requirement and slow operation. A good size is 256x256 or 512x512 pixels.

- - -

Learning More
-------------

The source code is organised into packages of code according to
functionality. The methods in each package are documented with description,
usage and references to documents with more information. To view help on a
specific method either open the file in a text editor or use the `help`
MATLAB command, e.g. `help JPEG.encoder`.

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


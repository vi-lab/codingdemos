MATLAB Image & Video Compression Demos
--------------------------------------

Demonstration applications and related code for teaching the principles and
implementations of image and video compression techniques.

# Quick Start

Begin the home demo screen with the command `start` in the root directory
of the project. To navigate between demos use the Home/Back and Forward
arrows in the screen toolbar. To show or hide more detailed elements of the
demos screens use the Advanced Mode button (the green plus button).

For more detailed information on each process see the documentation in each
package. Where appropriate each method should also contain references to
locations on the web or in standards documents where more information can
be found.

# Included MATLAB Packages

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

License & Authors
-----------------

Copyright 2011, The University Of Bristol
See License.m for the project code license.

Authors:

* [Stephen Ierodiaconou](http://www.stephenierodiaconou.com/)

Third party components are copyright their respective owners:

* [N-D discrete cosine transform](https://sites.google.com/site/myronenko/) - Andriy Myronenko, 2010

Bristol University Visual Information Laboratory
------------------------------------------------

[The Visual Information Laboratory](http://www.bristol.ac.uk/vi-lab/)
 exists to undertake innovative, collaborative and interdisciplinary research
resulting in world leading technology in the areas of computer vision, image
and video communications, content analysis and distributed sensor systems.
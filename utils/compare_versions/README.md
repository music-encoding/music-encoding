# MEI Comparison

The XSLT in this folder will create a comparison of two versions of MEI. It will require 
canonicalized versions of the *two mei-source.xml* files. The XSLT is supposed to operate 
on the *newer* version, while the filename of the *older* one is provided as the 
*old.version.filename* parameter to the XSLT. 

The resulting HTML file will depend on the *resources* folder for proper display. It is 
not fully correct HTML, as it was originally intended to be embedded in an older setup
of the MEI website. As of 2023-06, it will be rendered properly by current browsers, though. 

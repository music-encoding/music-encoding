Documentation generateGuidelines.xsl
==
This XSL makes use of XSLT3.0 features. Therefore, it requires the use of an advanced XSLT processor such as Saxon. It may be used to generate two different kinds of output:

 - several hundred files containing HTML snippets, which are intended to be uploaded to http://music-encoding.org, serving as online documentation of an MEI release, or
 - one single HTML file containing the full documentation of MEI, to bei used either as HTML or for conversion to PDF, utilizing the http://www.princexml.com converter.

It operates on a canonicalized ODD file, which can be obtained from within Oxygen (http://oxygenxml.com) or the MEI Customization service at http://custom.music-encoding.org. 

Setup:
-----
- It is assumed that two folders from the MEI sources are available in the same folder as the XSLT. These folder are the /css and /images folders from within /source/guidelines
- In order to generate a PDF from the output, http://www.princexml.com needs to be available. The output of this XSLT is tested against version 9 of PrinceXML.
- Call prince with something like ```prince MEI_Guidelines_v3.0.0.html MEI_Guidelines_v3.0.0.pdf``` (adjust as necessary)

Parameters:
-----
The XSLT takes the following parameters:
- **$version** *(optional)*: This parameter defines the version string to be used for this release. This does *not* affect the internal use in the MEI specification, just the strings used to generate the HTML and PDF outputs. If not specified, it will fall back to the value provided in the specification.

- $role (optional): This parameter identifies the type of input to the XSLT. A value of release (default)


- 
- **image.prefix** *(optional)*:
- **$imprint.date** *(optional)*:

The XSLT takes the following parameters:
- **$version** *(optional)*: This parameter defines the version string to be used for this release. This does not affect the internal use in the MEI specification, just the strings used to generate the HTML and PDF outputs. If not specified, it will fall back to the value provided in the specification.
- **$target** *(optional)*: This parameter defines the output format of the XSLT. A value of **pdf** *(default)* will generate one single HTML file, which can be converted to PDF. A value of website will result in a folder containing individual files for each chapter, element, model class, attribute class, data type and macro respectively. This output is intended for internal use on the http://music-encoding.org website and may be of limited value to others.
- **$role** *(optional)*: This parameter identifies the type of input to the XSLT. A value of **release** *(default)* results in an official release version of MEI, with appropriate credits. A value of **dev** is used to identify a build of the latest development version of MEI. A value of **custom** identifies a customization of MEI. In this case, the resulting HTML / PDF will not include the prose documentation, but only the technical specification of the resulting schema. Instead of writing an alternative to the existing documentation, it is encouraged to enter discussions with the MEI community with the possibility to eventually modify the MEI sources themselves. 
- **$image.prefix** *(optional)*: This parameter may be used to specify a (relative) path to the image files when generating the PDF. Defaults to **./**. 
- **$imprint.date* *(optional)*: This parameter may be used to give the correct date in the copyright statement when (re-)building older releases. Defaults to the **current year** (four digits). 
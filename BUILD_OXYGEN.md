### Building MEI with Oxygen XML Editor

#### Build a Specific Customization's RNG Schema

If you are not that comfortable with the command line, here we provide an alternative to build MEI by using Oxygen following these steps:

1. Open the customization file in Oxygen (make sure that it has the extension `.odd` and not `.xml`).

2. Click on the _Configure Transformation Scenario(s)_ button (the button with the wrench). This will open a window of the same name.

3. Check the _TEI ODD to RELAX NG XML_ check box.

4. Click on the _Duplicate_ button. This will open the _Edit Ant Scenario_ window.

5. Once in the _Edit Ant Scenario_, assign an appropriate name for the project (e.g., "MEI Mensural Schema - plica feature"). The storage option can be either _Project Options_ or _Global Options_.

6. Change its `defaultSource` parameter by:

   a. Clicking on the _Parameters_ tab.

   b. Locating the `defaultSource` parameter and double-clicking on its value to change it. This will open the _Edit Parameter_ window.

   c. Change the value of the `defaultSource` for the path of the MEI source file (`mei-source.xml`) found on your computer. You can do this by clicking on the folder icon to browse this file (it is located in your local copy of the music-encoding repo, in `music-encoding/source/mei-source.xml`) and opening it. If you are on Windows, make sure that the path starts with the *file* protocol, e.g. `file:/D:/music-encoding/source/mei-source.xml`.

   d. Click on the _OK_ button. The _Edit Parameter_ window will close.

7. Now, you will be back in the _Edit Ant Scenario_ window again. If you are satisfied with your changes, click on the _OK_ button. Otherwise, you could also edit the directory where your schema gets stored by clicking on the _Output_ tab.

8. Now, you will be back in your _Configure Transformation Scenario(s)_ window. In the _Projects_ or _Global_ section of the window based on your choice in step 5, you will find your _new project_ with the name you gave it in step 5. Click on it and then click on the _Applied associated_ button at the left-bottom corner of your window. This will build the schema.

Once the building is done, Oxygen will automatically open the schema. The schema file is also stored in the `music-encoding/customizations/out/` folder if you want to consult it later. You can change the location where the schema generated is saved by clicking on _Output_ in the _Edit Ant Scenario_ window and changing the file path.

#### Build Guidelines HTML

In this section, we will use Oxygen to generate the HTML document for the guidelines using the XSLT Stylesheet located at `music-encoding/utils/guidelines_xslt/odd2html.xsl`. The steps are the following:

1. Open the `mei-source.xml` file in Oxygen. This file is located in `music-encoding/source/mei-source.xml`.

2. Click on the _Configure Transformation Scenario(s)_ button (the button with the wrench). This will open a window of the same name.

3. Click on the _New_ button and select the _XML transformation with XSLT_ option. This will open the _New scenario_ window.

4. Assign a name to your new XML transformation.

5. In the _XSLT_ tab, look for the _XSL URL_ field and add the path to your `odd2html.xsl` file. You can do this by clicking on the folder icon to browse this file (it is located in your local copy of the music-encoding repo, in `music-encoding/utils/guidelines_xslt/odd2html.xsl`) and opening it.

6. Now, you will be back in the _New Scenario_ window again. If you are satisfied with your changes, click on the _OK_ button. Otherwise, you could also edit the _XML URL_ field for a particular folder, as well as the _Parameters_ to change the output folder.

7. Now, you will be back in your _Configure Transformation Scenario(s)_ window. In the _Global_ section of the window, you will find your new _XML transformation with XSLT_ with the name you gave it in step 4. Click on it and then click on the _Applied associated_ button at the left-bottom corner of your window. This will generate the HTML document for the guidelines.

After a few minutes, the results of this build can be found in the web folder (`music-encoding/source/web`). The guidelines are stored in the `index.html` file.

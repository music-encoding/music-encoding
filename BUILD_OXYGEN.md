### Building MEI with Oxygen XML Editor

If you are not that comfortable with the command line, here we provide an alternative to build MEI schema files for customizations and the HTML version of the Guidelines with Synchrosoft’s oXygen software family. Although the following documentation was developed with oXygen XML Editor, the illustrated workflows should also be possible in oXygen XML Developer and oXygen XML Author.

#### Build a Specific Customization’s RNG Schema

To build the RNG schema of a specific customization, follow these steps:

1. Open the customization file in oXygen.

   To make sure that step 2 works out of the box, make sure that it has the extension `.odd` and not `.xml`. This is necessary for oXygen to recognize the file as TEI ODD customization and offer you the pre-configured transformation scenario for generating RNG schema files from an ODD.

2. Click on the _Configure Transformation Scenario(s)_ button (the red play button with the wrench). This will open a window of the same name.

3. Check the _TEI ODD to RELAX NG XML_ check box.

4. Click on the _Duplicate_ button. This will open the _Edit Ant Scenario_ window.

5. Once in the _Edit Ant Scenario_, assign an appropriate name for the project (e.g., “MEI Mensural Schema - plica feature”). The storage option can be either _Project Options_ or _Global Options_.

6. Change its `defaultSource` parameter by:

   a. Clicking on the _Parameters_ tab.

   b. Locating the `defaultSource` parameter and double-clicking on its value to change it. This will open the _Edit Parameter_ window.

   c. Change the value of the `defaultSource` to the path of the MEI source file (`mei-source.xml`) found on your computer. You can do this by clicking on the folder icon and browsing to the file location (it is located in your local copy of the music-encoding repo, in `music-encoding/source/mei-source.xml`). Select the file and click _Open_ Button. If you are on Windows, make sure that the path starts with the *file* protocol, e.g. `file:/D:/music-encoding/source/mei-source.xml`.

   d. Back in the _Edit Parameter_ window click on the _OK_ button. The _Edit Parameter_ window will close.

7. Now, you will be back in the _Edit Ant Scenario_ window again. If you are satisfied with your changes, click on the _OK_ button. Otherwise, you could also edit the directory where your schema gets stored by clicking on the _Output_ tab.

8. Now, you will be back in your _Configure Transformation Scenario(s)_ window. In the _Projects_ or _Global_ section of the window based on your choice in step 5, you will find your _new project_ with the name you gave it in step 5. Click on it and then click on the _Applied associated_ button at the left-bottom corner of your window. This will build the schema.

Once the building is done, Oxygen will automatically open the schema. The schema file is also stored in the `music-encoding/customizations/out/` folder if you want to consult it later. You can change the location where the schema generated is saved by clicking on _Output_ in the _Edit Ant Scenario_ window and changing the file path.

#### Build Guidelines HTML

In this section, we will use Oxygen to generate the HTML document for the guidelines using the XSLT Stylesheet located at `music-encoding/utils/guidelines_xslt/odd2html.xsl`. The steps are the following:

1. Run the following command (as described in the `BUILD_COMMANDLINE.md` file) to build the compiled ODD of a specific customization (e.g., `customizations\mei-cmn.xml`)

```shell
       ant -Dcustomization.path="[/ABSOLUTE/PATH/TO/YOUR/CUSTOMIZATION]" build-compiled-odd
```
This outputs the compiled ODD file: `music-encoding/dist/schemata/*.odd`.

2. Click on the _Configure Transformation Scenario(s)_ button (the button with the wrench). This will open a window of the same name.

3. Click on the _New_ button and select the _XML transformation with XSLT_ option. This will open the _New scenario_ window. Assign a name to your new XML transformation.

3. In the _XML URL_ field, add the path to your compiled ODD file (e.g., `music-encoding/dist/schemata/mei-cmn.odd`). You can do this by clicking on the folder icon to browse this file and opening it.


4. In the _XSLT_ tab, look for the _XSL URL_ field and add the path to your `odd2html.xsl` file. You can do this by clicking on the folder icon to browse this file (it is located in your local copy of the music-encoding repo, in `music-encoding/utils/guidelines_xslt/odd2html.xsl`) and opening it.
  
   Here’s a configuration example that uses project-relative paths:

<img width="400" alt="oXygen transformation scenario dialog box" src="https://github.com/user-attachments/assets/cfac9190-a4cc-4700-9338-1cc1a240416a" />

5. Now, you will be back in the _New Scenario_ window again. If you are satisfied with your changes, click on the _OK_ button. Otherwise, you could also edit the _XML URL_ field for a particular folder, as well as the _Parameters_ to change the output folder. 

6. Now, you will be back in your _Configure Transformation Scenario(s)_ window. In the _Global_ section of the window, you will find your new _XML transformation with XSLT_ with the name you gave it in Step 4. Click on it and then click on the _Applied associated_ button at the left-bottom corner of your window. This will generate the HTML document for the guidelines.





After a few minutes, the results of this build can be found in the web folder (`music-encoding/dist/guidelines/web`). The guidelines are stored in the `index.html` file.

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

1. Open `build.xml` or any other XML file in oXygen. Create a new [ant task](https://www.oxygenxml.com/doc/versions/28.1/ug-editor/topics/ant-transformation.html?hl=ant%2Ctransformation) in oXygen with the following parameters:

   * Name: `build-compiled-odd`
   * Ant build file: `${pd}/build.xml`
   * Build target: `build-compiled-odd`

   In the parameters tab, add parameter `customization.path` with the value of the path to your customization file (e.g., `${pd}/customizations/mei-cmn.xml`). After applying this ant task, you will find the compiled ODD file: `music-encoding/dist/schemata/*_compiled.odd`.

   

2. Open the compiled ODD file in oXygen (e.g. `music-encoding/dist/schemata/mei-cmn_compiled.odd`). Configure a new [transformation scenario](https://www.oxygenxml.com/doc/versions/28.1/ug-editor/topics/xml-transformation-with-xslt.html) with the following parameters:

   * Name: `odd2html`
   * XML URL: `${currentFileURL}`
   * XSL URL: `${pdu}/utils/guidelines_xslt/odd2html.xsl`

   <img width="300"  alt="oXygen transformation scenario dialog box" src="https://github.com/user-attachments/assets/ccc7e059-38b0-4d44-83ab-ceaf4d612831" />

   Afer applying this transformation the output files will be in `dist/guidelines/web`. 

   Note that `assets/` folder is only copied by the respective ant task `build-guidelines-html` and not by the XSLT transformation. If you want to copy the `assets/` folder, you can do it manually or use the ant task.

   Note that the `${pd}` variable is a built-in variable in oXygen that points to the directory of the currently opened file.  You may replace it with an absolute path to your customization file.
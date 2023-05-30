# Building MEI on the command line

1. Build requirements

   To build all possible artifacts, your build system has to meet the following prerequisites:

   | Prerequisite | Recommended version |
   |----|----------------|
   |Java| 17 (at least Java 8 at runtime to support Apache Ant™)|
   |Apache Ant|1.10.13|
   |Verovio Toolkit|3.15|
   |Prince XML|15.1|
   |Saxon HE*| 11.4 |
   |Xerces*|Synchrosoft patched version 25.1.0.1|

   \* automatically pulled during build execution

2. Check if your system meets the build requirements

   * Is Java 8 or above available on your machine?

     Java 8 or above is needed for the build process driven by Apache Ant™ (see below).
     To check for Java on your machine, run the following command:

     ```shell
     java -version
     ```

     This should return something similar to:

     ```shell
     openjdk version "17.0.2" 2022-01-18 LTS
     OpenJDK Runtime Environment Zulu17.32+13-CA (build 17.0.2+8-LTS)
     OpenJDK 64-Bit Server VM Zulu17.32+13-CA (build 17.0.2+8-LTS, mixed mode, sharing)
     ```

     If the version number indicated is lower than `8.0.0` or if the command returns an empty string, please update or install Java according to an installation instruction matching your operating system (to be found on the internet).

   * Is Apache Ant™ installed?

     [Apache Ant™](https://ant.apache.org/manual/install.html) is a library for building software projects and drives the creation of MEI schemata and guidelines from the ODD source files.

     Run the following command to see if it is available on your system:

     ```shell
     ant -version
     ```

     This should return something similar to:

     ```shell
     Apache Ant™ version 1.10.13 compiled on September 27 2020
     ```

     We recommend using the latest stable release of Apache Ant™. If your system has an older version of Apache Ant™ installed you might still give it a try though. If the prompt returns an empty string, please refer to the [Apache Ant™ Installation Instructions](https://ant.apache.org/manual/install.html).

  * Is Verovio installed for generating example images locally?

    To build the images with Verovio, you need Python3 to be installed with the `verovio` module. These can be installed with

    ```shell
    pip install verovio lxml
    ```

2. Initialize the build process

   * Switch to your clone’s directory:

     ```shell
     cd [YOUR-CLONE-LOCATION]
     ```

   * Call the Apache Ant™ init task:

     ```shell
     ant init
     ```

3. Run the build process

   * Build guidelines HTML:

     ```shell
     ant -lib lib/saxon/saxon-he-11.4.jar build-guidelines-html
     ```

     The results of this build can be found in the web folder (`music-encoding/dist/guidelines/dev/web`). The guidelines are stored in the `index.html` file.

     To generate the example images with Verovio, you need to run:
     ```shell
     ant generate-images-py
     ```

   * Build a specific customization's RNG schema:

     ```shell
     ant -lib lib/saxon/saxon-he-11.4.jar -Dcustomization.path="[PATH/TO/YOUR/CUSTOMIZATION]" build-rng
     ```

   * Build everything (all customizations shipped with this repository, compiled ODDs for each customization, guidelines HTML):

     ```shell
     ant -lib lib/saxon/saxon-he-11.4.jar
     ```

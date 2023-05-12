# Building MEI on the command line

1. Check if your system meets the build requirements

   * Is Java 8 or above available on your machine?

     Java 8 or above is needed for the build process driven by Apache Ant™ (see below).
     To check for Java on your machine, run the following command:

     ```shell
     java -version
     ```

     This should return something similar to:

     ```shell
     openjdk version "11.0.9" 2020-10-20
     OpenJDK Runtime Environment (build 11.0.9+11)
     OpenJDK 64-Bit Server VM (build 11.0.9+11, mixed mode)
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

   * Build a specific customization's RNG schema:

     ```shell
     ant -lib lib/saxon/saxon-he-11.4.jar -Dcustomization.path="[PATH/TO/YOUR/CUSTOMIZATION]" build-rng
     ```

   * Build everything (all customizations shipped with this repository, compiled ODDs for each customization, guidelines HTML):

     ```shell
     ant -lib lib/saxon/saxon-he-11.4.jar
     ```
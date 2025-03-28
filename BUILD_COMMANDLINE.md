# Building MEI on the command line

1. Build requirements

   To build all possible artifacts, your build system has to meet the following prerequisites:

   | Prerequisite | Recommended version |
   |----|----------------|
   |Java| Java Development Kit (JDK) 17 recommended (at least Java 8 at runtime to support Apache Ant™)|
   |Apache Ant|1.10.14|
   |Verovio Toolkit|5.0.0|
   |Prince XML|15.3|
   |Saxon HE*|12.5|
   |TEI Stylesheets*|7.57.1|
   |Xerces*|Synchrosoft patched version 26.1.0.1|

   \* automatically pulled during build execution

2. Check if your system meets the build requirements

   * Is Java 8 or above available on your machine?

     Java 8 is the minimum version needed for the build process driven by Apache Ant™ (see below). However, we recommend using JDK 17.
     To check for Java on your machine, run the following command:

     ```shell
     java -version
     ```

     This should return something similar to:

     ```shell
     openjdk version "17.0.7" 2023-04-18
     OpenJDK Runtime Environment Temurin-17.0.7+7 (build 17.0.7+7)
     OpenJDK 64-Bit Server VM Temurin-17.0.7+7 (build 17.0.7+7, mixed mode, sharing)
     ```

     If the version number indicated is lower than `8.0.0` or if the command returns an empty string, please update or install Java according to an installation instruction matching your operating system (to be found on the internet). The Java Development Kit we use in our [Docker Container](https://github.com/music-encoding/docker-mei) is Eclipse Temurin™, which is easy to [install](https://adoptium.net/de/installation/) on Linux, macOS or Windows.

   * Is Apache Ant™ installed?

     [Apache Ant™](https://ant.apache.org/manual/install.html) is a library for building software projects and drives the creation of MEI schemata and guidelines from the ODD source files.

     Run the following command to see if it is available on your system:

     ```shell
     ant -version
     ```

     This should return something similar to:

     ```shell
     Apache Ant(TM) version 1.10.14 compiled on August 16 2023
     ```

     We recommend using the latest stable release of Apache Ant™. If your system has an older version of Apache Ant™ installed you might still give it a try though. If the prompt returns an empty string, please refer to the [Apache Ant™ Installation Instructions](https://ant.apache.org/manual/install.html) or any other applicable installation instruction.

      * **macOS or Linux:** e.g. the [Homebrew Package Manager](https://brew.sh/index_de) offers an easy installation method for both a JDK and Apache Ant™.
      * **Windows:** e.g. the [Chocolatey Package Manager](https://chocolatey.org) can be used to install both a JDK and Apache Ant™.

   * Is Verovio installed for generating example images locally?

     Optional: If you wish, you can use a Python virtual environment to manage your dependencies. Before installing Verovio, create and activate a virtual environment.

     ```shell
     python3 -m venv ./.venv
     source ./.venv/bin/activate
     ```

    This will install your Python libraries in the local `.venv` directory. Once your virtual environment is active you can continue to installing Verovio.

    To build the images with Verovio, you need Python3 to be installed with the `verovio` module. This can be installed with:

    ```shell
    pip install verovio
    ```

3. Build MEI artifacts

   * Switch to your clone’s directory:

     ```shell
     cd [YOUR-CLONE-LOCATION]
     ```

   * Call an Apache Ant™ task

     For building any MEI artifacts you generally call Apache Ant™ by typing `ant` followed by a space and the name of the desired target:

     ```shell
     ant [TASKNAME]
     ```

     * Build the RNG schema of a specific customization:

       ```shell
       ant -Dcustomization.path="[/ABSOLUTE/PATH/TO/YOUR/CUSTOMIZATION]" build-rng
       ```

     * Build the compiled ODD of a specific customization:

       ```shell
       ant -Dcustomization.path="[/ABSOLUTE/PATH/TO/YOUR/CUSTOMIZATION]" build-compiled-odd
       ```

     * Build guidelines HTML:

       ```shell
       ant build-guidelines-html
       ```

       The results of this build can be found in the web folder (`music-encoding/dist/guidelines/web`). The guidelines are stored in the `index.html` file.

     * Generate the example images with Verovio:

       ```shell
       ant generate-images-py
       ```

       **Note:** If you have installed your dependencies in a virtual environment, be sure to activate it prior to calling the Ant task. Activate it using:

       ```shell
       source ./.venv/bin/activate
       ```

     * Build everything (all customizations shipped with this repository, compiled ODDs for each customization, guidelines HTML and PDF if Prince is available):

       ```shell
       ant dist
       ```

       or, because the `dist` target is the default target, just:

       ```shell
       ant
       ```

       Please be aware that depending on your system configuration some targets might fail, e.g. generating the PDF if you do not have Prince XML installed.

## Available Targets

The following targets can be called using `ant <target>`:

| target                | description     |
|-----------------------|-----------------|
| `dist` (or no target) | Default main target; equivalent to calling ant without any target. Builds all artifacts, i.e., RNG and compiled ODDs of all customizations, guidelines html and PDF.  |
| `canonicalize-source` | Creates a canonicalized version of the mei-source.xml, i.e., resolves xincludes and puts result in `build/mei-source_canonicalized_v{mei-version}`. |
| `validate-source` | Validates the canonicalized source. This target will be triggered before all `build-...` targets. |
| `build-compiled-odds` | Builds the compiled ODD files for all MEI customizations. |
| `build-compiled-odd -Dcustomization.path="[ABSOLUTE/PATH/TO/YOUR/CUSTOMIZATION]"` | Builds the compiled ODD of a specific customization submitted as as absolute path with `-Dcustomization.path` input param. |
| `build-customizations` | Builds the RNG schemata for all MEI customizations. |
| `build-rng -Dcustomization.path="[ABSOLUTE/PATH/TO/YOUR/CUSTOMIZATION]"` | Builds the RNG schema of a specific customization submitted as absolute path with `-Dcustomization.path` input param. |
| `build-guidelines-html` | Builds the HTML version of the MEI guidelines. |
| `build-guidelines-pdf` | Builds the PDF version of the MEI guidelines. (Calls `build-guidelines-html` before execution.) |
| `info`| Displays the versions of Ant and Java (JDK). |
| `init` | Initializes the build environment, i.e., checks if TEI Stylesheets, Saxon, Xerces and Schematron are available, and if not, it downloads everything into the `lib` folder. Checks if Prince is available. |
| `init-mei-classpath` | Initializes the mei.classpath, which is essential for the schema generation, by prepending the jar files contained in the lib directory to the java classpath. Will be called automatically if needed. |
| `compare-versions` | Compares the canonicalized sources of the MEI dev version with the previous stable version and creates an HTML output; custom versions and output folder can be set via `-Dsource`, `-Dold` and `-Doutput` input params. |
| `clean` | Deletes the following directories: `build`, `dist` and `temp`. |
| `reset` | Resets the build environment. Same as `clean`, but additionally deletes the `lib` directory with the TEI Stylesheets and the jar files. |

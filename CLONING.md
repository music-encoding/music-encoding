# Cloning this repository

There are several reasons why you might want to create a clone of this repository on your local machine. These range from experimenting with the codebase, over creating your own schema customizations, to contributing to the development of the MEI schema and guidelines.

For a proper setup of your clone, you need to make a so-called recursive clone.

## Creating a recursive clone of this repository

Git offers a mechanism called `submodule` that allows you to reference third-party code used in your own project without including the code in your repository. This mechanism is used in the music-encoding repository in order to include the [TEI Stylesheets](https://github.com/TEIC/Stylesheets); these are needed for transforming the ODD files, e.g. to RNG schema files. Cloning a repository including the referenced submodules is referred to as _creating a recursive clone_.

  * If you do not have a clone on your local machine yet run the following from your command line:

    ```shell
    git clone https://github.com/music-encoding/music-encoding.git --recursive
    ```

  * If you already have a clone on your system you still might have to initialize the submodules by running the following commands from the command line:

    Switch to your clone's directory:

    ```shell
    cd [YOUR-CLONE-LOCATION]
    ```

    Initialize the submodules:

    ```shell
    git submodule init
    ```

    Update the submodules:

    ```shell
    git submodule update
    ```

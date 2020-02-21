# Pushing data from the board sensors to the cloud storage

## Mbed-cli notes

```
$ mbed new .  // will create files: .med mbed-os.lib mbed_app.json mbed_settings.py and folder: mbed-os
$ mbed add https://github.com/ARMmbed/mbed-cloud-client

$ mbed deploy --help
usage: mbed deploy [-h] [-I] [--depth [DEPTH]] [--protocol [PROTOCOL]]
                   [--insecure] [--offline] [--no-requirements] [-v] [-vv]

Import missing dependencies in an existing program or library.
Hint: Use "mbed import <URL>" and "mbed add <URL>" instead of cloning
manually and then running "mbed deploy"

optional arguments:
  -h, --help            show this help message and exit
  -I, --ignore          Ignore errors related to cloning and updating.
  --depth [DEPTH]       Number of revisions to fetch from the remote
                        repository. Default: all revisions.
  --protocol [PROTOCOL]
                        Transport protocol for the source control management.
                        Supported: https, http, ssh, git. Default: inferred
                        from URL.
  --insecure            Allow insecure repository URLs. By default mbed CLI
                        imports only "safe" URLs, e.g. based on standard ports
                        - 80, 443 and 22. This option enables the use of
                        arbitrary URLs/ports.
  --offline             Offline mode will force the use of locally cached
                        repositories and prevent requests to remote
                        repositories.
  --no-requirements     Disables checking for and installing any requirements.
  -v, --verbose         Verbose diagnostic output
  -vv, --very_verbose   Very verbose diagnostic output

$ mbed compile --help
usage: mbed compile [-h] [-t TOOLCHAIN] [-m TARGET] [-D MACRO]
                    [--profile PROFILE] [--library] [--config]
                    [--prefix CONFIG_PREFIX] [--source SOURCE] [--build BUILD]
                    [-c] [-f] [--sterm] [--baudrate BAUDRATE]
                    [-N ARTIFACT_NAME] [-S [{matrix,toolchains,targets}]]
                    [--app-config APP_CONFIG] [-v] [-vv]

Compile this program using the mbed build tools.

optional arguments:
  -h, --help            show this help message and exit
  -t TOOLCHAIN, --toolchain TOOLCHAIN
                        Compile toolchain. Example: ARM, GCC_ARM, IAR
  -m TARGET, --target TARGET
                        Compile target MCU. Example: K64F, NUCLEO_F401RE,
                        NRF51822...
  -D MACRO, --macro MACRO
                        Add a macro definition
  --profile PROFILE     Path of a build profile configuration file (or name of
                        Mbed OS profile). Default: develop
  --library             Compile the current program or library as a static
                        library.
  --config              Show run-time compile configuration
  --prefix CONFIG_PREFIX
                        Restrict listing to parameters that have this prefix
  --source SOURCE       Source directory. Default: . (current dir)
  --build BUILD         Build directory. Default: build/
  -c, --clean           Clean the build directory before compiling
  -f, --flash           Flash the built firmware onto a connected target.
  --sterm               Open serial terminal after compiling. Can be chained
                        with --flash
  --baudrate BAUDRATE   Serial terminal communication baudrate. Default: 9600
  -N ARTIFACT_NAME, --artifact-name ARTIFACT_NAME
                        Name of the built program or library
  -S [{matrix,toolchains,targets}], --supported [{matrix,toolchains,targets}]
                        Shows supported matrix of targets and toolchains
  --app-config APP_CONFIG
                        Path of an application configuration file. Default is
                        to look for "mbed_app.json".
  -v, --verbose         Verbose diagnostic output
  -vv, --very_verbose   Very verbose diagnostic output
```

## Mbed-cli in Docker
Clone this project:
```
cd ~/GIT
git clone git@github.com:mlubinsky-arm/sensor2cloud.git
```
Install Docker image with Mbed-cli from
<https://hub.docker.com/r/mbedos/mbed-os-env>
```
docker pull mbedos/mbed-os-env
```
Run container and mount the volume with git code:
```
docker run -v /Users/miclub01/GIT/sensor2cloud:/mnt/sensor2cloud -i -t mbedos/mbed-os-env
cd /mnt/sensor2cloud
mbed deploy  // to get all dependencies
mbed compile -m NUCLEO_H743ZI2 -t GCC_ARM
```

## Pelion Device Management Links
<https://os.mbed.com/teams/mbed-os-examples/code/mbed-os-example-pelion/>

<https://www.pelion.com/docs/device-management/current/connecting/device-management-client-tutorials.html>

<https://github.com/ARMmbed/mbed-cloud-client-example>

<https://github.com/BlackstoneEngineering/aiot-workshop>

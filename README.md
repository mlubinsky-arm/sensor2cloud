# Pushing data from the board sensors to the cloud storage

## Mbed-cli in Docker

Compiling in docker may be slow 1st time because the entire mbedos will be compiled from scratch.
See discussion here:
<https://github.com/ARMmbed/mbed-cli/issues/894>

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
mbed deploy  // to get all dependencies described in files with .lib extension
mbed ls .    // see dependecy and lib versions 
mbed compile -m NUCLEO_H743ZI2 -t GCC_ARM
```
The compilation will generates the error:
```
./mbed_cloud_dev_credentials.c:20:2: error: #error "Replace mbed_cloud_dev_credentials.c with your own developer cert."
   20 | #error "Replace mbed_cloud_dev_credentials.c with your own developer cert."
```
It is because the cerificate is not provided in this repo. 
To generate mbed_cloud_dev_credentials.c file follow instructions:
 <https://www.pelion.com/docs/device-management/current/provisioning-process/provisioning-development-devices.html>

Configure Mbed CLI to use your Device Management account and board
```
mbed config -G CLOUD_SDK_API_KEY <PELION_DM_API_KEY>
```
Initialize firmware credentials (done once per repository).
Download a developer certificate and to create the update-related configuration for your device
```
mbed dm init -d "<your company name in Pelion DM>" --model-name "<product model identifier>" -q --force

mbed device-management init -d arm.com --model-name example-app --force -q
```

The file mbed_cloud_dev_credentials.c should look like this:
```
const char MBED_CLOUD_DEV_BOOTSTRAP_ENDPOINT_NAME[] = "017064b32c8c724d89b03fd003c00000";
const char MBED_CLOUD_DEV_ACCOUNT_ID[] = "01703ad30d2d8aeda61f134c00000000";
const char MBED_CLOUD_DEV_BOOTSTRAP_SERVER_URI[] = "coaps://bootstrap.us-east-1.mbedcloud.com:5684?aid=01703ad30d2d8aeda61f134c00000000";

const uint8_t MBED_CLOUD_DEV_BOOTSTRAP_DEVICE_CERTIFICATE[] = 
{ 0x30, 0x82, 0x02, 0x85, 0x30, 0x82, 0x02, 0x2a,
 0xa0, 0x03, 0x02, 0x01, 0x02, 0x02, 0x11, 0x00,
 
};
const uint8_t MBED_CLOUD_DEV_BOOTSTRAP_SERVER_ROOT_CA_CERTIFICATE[] = 
{ 0x30, 0x82, 0x02, 0x1f, 0x30, 0x82, 0x01, 0xc5,
 0xa0, 0x03, 0x02, 0x01, 0x02, 0x02, 0x10, 0x3c,
};

onst uint8_t MBED_CLOUD_DEV_BOOTSTRAP_DEVICE_PRIVATE_KEY[] = 
{ 0x30, 0x81, 0x93, 0x02, 0x01, 0x00, 0x30, 0x13,
 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
};
 ```
Also the file update_default_resources.c should be updated.
Look here for instructions:
<https://www.pelion.com/docs/device-management/v1.5/updating-firmware/setting-up.html>

Try compile again. It should work now.

## Mbed-cli notes

```
$ mbed new .  // will create files: .med mbed-os.lib mbed_app.json mbed_settings.py and folder: mbed-os
$ mbed add https://github.com/ARMmbed/mbed-cloud-client
```
### mbed deploy
```
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
```
### mbed compile
```
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

## Pelion Device Management Links
<https://os.mbed.com/teams/mbed-os-examples/code/mbed-os-example-pelion/>

<https://www.pelion.com/docs/device-management/current/connecting/device-management-client-tutorials.html>

<https://github.com/ARMmbed/mbed-cloud-client-example>

<https://github.com/BlackstoneEngineering/aiot-workshop>

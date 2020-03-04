# Pushing data from the board sensors to the cloud storage

## Mbed-cli in Docker

Install Docker image with Mbed-cli from <https://hub.docker.com/r/mbedos/mbed-os-env>
```
docker pull mbedos/mbed-os-env
```
Run container:
```
docker run  -i -t mbedos/mbed-os-env
```
Let see what is inside this container:
```
$ python3 -V
Python 3.6.9

$ pip3 list | grep mbed

mbed-cli (1.10.2)
mbed-cloud-sdk (2.0.8)       https://github.com/ARMmbed/mbed-cloud-sdk-python
mbed-flasher (0.10.1)
mbed-greentea (1.7.4)
mbed-host-tests (1.5.10)
mbed-ls (1.7.10)
mbed-os-tools (0.0.12)
```
Compiling mbed project in docker may be slow 1st time because the entire MbedOS will be compiled from scratch.
See discussion here: <https://github.com/ARMmbed/mbed-cli/issues/894>

 

### Download your mbed project and make it visible to docker:

Clone this project:
```
cd ~/GIT
git clone git@github.com:mlubinsky-arm/sensor2cloud.git
```
Run container and mount the volume with your project code:
```
docker run -v /Users/miclub01/GIT/sensor2cloud:/mnt/sensor2cloud -i -t mbedos/mbed-os-env
 
cp -r  /mnt/sensor2cloud ~           # To speed up compilation copy code into docker

Another option - just get the code directly from cloud to docker:
```
mbed import https://github.com/mlubinsky-arm/sensor2cloud

cd ~/sensor2cloud

mbed deploy  // to get all dependencies described in files with .lib extension
mbed ls .    // see dependecy and lib versions 
mbed config -G CLOUD_SDK_API_KEY <PELION_DM_API_KEY>
mbed dm init -d "arm.com" --model-name "mbed" -q –-force
mbed compile -m NUCLEO_H743ZI2 -t GCC_ARM --flash -DRESET_STORAGE
Comment: flag -DRESET_STORAGE should be applied only once  

Copied Image  ./BUILD/NUCLEO_H743ZI2/GCC_ARM/sensor2cloud.bin to bard
Edit main.cpp - modify print statement to make a visible difference
mbed compile -m NUCLEO_H743ZI2 -t GCC_ARM
```
Run device update:
```
mbed dm update device -D 0170a6e08345000000000001001a30be -m NUCLEO_H743ZI2 --no-cleanup

[mbed] Working path "/Users/miclub01/GIT/sensor2cloud" (program)
[INFO] 2020-03-04 10:58:43 - manifesttool.update_device - Using sensor2cloud_update.bin-2020-03-04T10:58:43 as payload name.
[INFO] 2020-03-04 10:58:43 - manifesttool.update_device - Using sensor2cloud_update.bin-2020-03-04T10:58:43-manifest as manifest name.
[INFO] 2020-03-04 10:58:44 - manifesttool.update_device - Created new firmware at http://firmware-catalog-media-ca57.s3.dualstack.us-east-1.amazonaws.com/sensor2cloud_update_0de5abe0583043409985d246df2b9284.bin
[INFO] 2020-03-04 10:58:44 - manifesttool.update_device - Created temporary manifest file at /var/folders/jg/wxg_cwrx5_n90vf4vt8883nh0000gn/T/tmpri0jxp6m/manifest
[INFO] 2020-03-04 10:58:45 - manifesttool.update_device - Created new manifest at http://firmware-catalog-media-ca57.s3.dualstack.us-east-1.amazonaws.com/manifest_42cfc977f0be4218b9663f7e440085e1
[INFO] 2020-03-04 10:58:45 - manifesttool.update_device - Manifest ID: 0170a6ea1abb00000000000100100234
[INFO] 2020-03-04 10:58:45 - manifesttool.update_device - Campaign successfully created. Current state: 'draft'
[INFO] 2020-03-04 10:58:45 - manifesttool.update_device - Campaign successfully created. Filter result: {'id': {'$eq': '0170a6e08345000000000001001a30be'}}
[INFO] 2020-03-04 10:58:45 - manifesttool.update_device - Starting the update campaign...
[INFO] 2020-03-04 10:58:45 - manifesttool.update_device - Campaign successfully started. Current state: 'scheduled'. Checking updates..
[INFO] 2020-03-04 10:58:45 - manifesttool.update_device - Current state: 'checkedmanifest'
[INFO] 2020-03-04 10:58:45 - manifesttool.update_device - Current state: 'devicecopy'
[INFO] 2020-03-04 10:58:46 - manifesttool.update_device - Current state: 'publishing'
[INFO] 2020-03-04 11:01:48 - manifesttool.update_device - Current state: 'autostopped'
[INFO] 2020-03-04 11:01:48 - manifesttool.update_device - Finished in state: 'autostopped'

At this moment  the new image  deployed to board !
```

### Get a device cerificate: download  mbed_cloud_dev_credentials.c from Pelion Device Manager
 
To generate mbed_cloud_dev_credentials.c file follow instructions:
 <https://www.pelion.com/docs/device-management/current/provisioning-process/provisioning-development-devices.html>

Download  mbed_cloud_dev_credentials.c from  https://portal.mbedcloud.com/identity/certificates/list/ and put it in the current project folder.
This is the important lines in the file, which can be tracked in Pelion Web UI
```
const char MBED_CLOUD_DEV_BOOTSTRAP_ENDPOINT_NAME[] = "017064b32c8c724d89b03fd003c00000";  // Pelion deviceId
const char MBED_CLOUD_DEV_ACCOUNT_ID[] =  "0170a2c070bf000000000001001883bd";  // Pelion campain id
```



### Initialize the firmware update credentials

To enable you to create an update image that can be installed on the device, you need to create an authentication certificate that is delivered with the firmware update.  You use the manifest tool to generate the authentication certificate
Look here for instructions:
<https://www.pelion.com/docs/device-management/v1.5/updating-firmware/setting-up.html>

File which will be updated: update_default_resources.c

The commands ```mbed dm``` and ```manifest-tool``` are the same - here is the proof:

The help  for ``mbed dm``:
```
mbed dm --help
usage: mbed device-management [-h] [-l {debug,info,warning,exception}]
                              [--version]
                              {create,parse,verify,cert,init,sign,update} ...

Create or transform a manifest. Use mbed device-management [command] -h for
help on each command.

positional arguments:
  {create,parse,verify,cert,init,sign,update}
    create              Create a new manifest
    parse               Parse an existing manifest
    verify              Verify an existing manifest
    cert                Create or examine a certificate
    init                Set default values for manifests
    sign                Sign an existing manifest
    update              Work with the Device Management Update service

optional arguments:
  -h, --help            show this help message and exit
  -l {debug,info,warning,exception}, --log-level {debug,info,warning,exception}
  --version             display the version
```
The help for manifest-tool:
```
manifest-tool --help
usage: manifest-tool [-h] [-l {debug,info,warning,exception}] [--version]
                     {create,parse,verify,cert,init,sign,update} ...

Create or transform a manifest. Use /usr/local/bin/manifest-tool [command] -h
for help on each command.

positional arguments:
  {create,parse,verify,cert,init,sign,update}
    create              Create a new manifest
    parse               Parse an existing manifest
    verify              Verify an existing manifest
    cert                Create or examine a certificate
    init                Set default values for manifests
    sign                Sign an existing manifest
    update              Work with the Device Management Update service

optional arguments:
  -h, --help            show this help message and exit
  -l {debug,info,warning,exception}, --log-level {debug,info,warning,exception}
  --version             display the version
```

Download a developer certificate and to create the update-related configuration for your device:
```
mbed dm init -d "<your company name in Pelion DM>" --model-name "<product model identifier>" -q --force

Example:
mbed dm init -d arm.com --model-name example-app  -q --force
```

##  The Firmware Update Links

<https://www.pelion.com/docs/device-management/current/updating-firmware/integrating-the-client-in-your-application.html>

<https://www.pelion.com/docs/device-management/current/updating-firmware/preparing-manifests.html>

<https://www.pelion.com/docs/device-management/current/updating-firmware/manifest-tool.html>

## Pelion Device Management Links
<https://os.mbed.com/teams/mbed-os-examples/code/mbed-os-example-pelion/>

<https://www.pelion.com/docs/device-management/current/connecting/device-management-client-tutorials.html>

<https://github.com/ARMmbed/mbed-cloud-client-example>

<https://github.com/BlackstoneEngineering/aiot-workshop> 


## Pelion REST API

Host: https://api.us-east-1.mbedcloud.com

<https://www.pelion.com/docs/device-management/current/service-api-references/update-service.html>

<https://www.pelion.com/docs/device-management/current/service-api-references/service-api-documentation.html>

https://armmbed.github.io/mbed-cloud-sdk-documentation/#introduction

<https://github.com/ARMmbed/mbed-cloud-sdk-python>

## Mbed-cli Notes

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


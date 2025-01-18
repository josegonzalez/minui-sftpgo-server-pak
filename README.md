# trimui-brick-sftpgo-server.pak

A TrimUI Brick app wrapping [`sftpgo`](https://github.com/drakkan/sftpgo), an FTP server.

## Requirements

- Docker (for building)

## Building

```shell
make release
```

## Installation

1. Mount your TrimUI Brick SD card.
2. Download the latest release from Github. It will be named `FTP.Server.pak.zip`.
3. Copy the zip file to `/Tools/tg3040/FTP Server.pak.zip`.
4. Extract the zip in place, then delete the zip file.
5. Confirm that there is a `/Tools/tg3040/FTP Server.pak/launch.sh` file on your SD card.
6. Unmount your SD Card and insert it into your TrimUI Brick.

## Usage

> [!NOTE]
> The default credentials are:
>
> - `minui:minui`

This pak runs on ports 21 (FTP) and 8888 (HTTP UI).

### daemon-mode

By default, `sftpgo` runs as a foreground process, terminating on app exit. To run `sftpgo` in daemon mode, create a file named `daemon-mode` in the pak folder. This will turn the app into a toggle for `sftpgo`.

### ftp-port

By default, `sftpgo` runs the FTP server on port `21`. To run it on a different port, create a file named `ftp-port` in the pak folder with the desired port number as the contents of the file. This will be used on subsequent runs for the port to run the FTP server on.

### http-port

By default, `sftpgo` runs the http ui on port `8888`. To run it on a different port, create a file named `http-port` in the pak folder with the desired port number as the contents of the file. This will be used on subsequent runs for the port to run the http ui on.

### password

Creating a file named `password` will result in the contents of that file being used as the password for the `minui` user. If not specified, the password is set to `minui`.

# trimui-brick-sftpgo-server.pak

A TrimUI Brick app wrapping [`sftpgo`](https://github.com/drakkan/sftpgo), an sftp server.

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

### daemon-mode

By default, `sftpgo` runs as a foreground process, terminating on app exit. To run `sftpgo` in daemon mode, create a file named `daemon-mode` in the pak folder. This will turn the app into a toggle for `sftpgo`.

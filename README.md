# pibox-framebuffer

The PiBox's display server. Lightweight Go binary to draw images to the framebuffer

## Installation

* Enable SPI using `raspi-config` -> `Interfacing Options` -> `SPI`
* Reboot to enable SPI, `sudo reboot now`
* Download the latest [release](https://github.com/kubesail/pibox-framebuffer/releases)
* Set permissions, `chmod +x pibox-framebuffer`
* Run the binary using `./pibox-framebuffer`

Alternatively, install it as a service:

    mkdir /opt/kubesail
    mv pibox-framebuffer /opt/kubesail/pibox-framebuffer
    # Download the .service file from this repo:
    curl -L https://raw.githubusercontent.com/kubesail/pibox-framebuffer/main/pibox-framebuffer.service -o /etc/systemd/system/pibox-framebuffer.service
    systemctl daemon-reload
    systemctl enable pibox-framebuffer

## Configuration

The following environment variables can be used to configure the display:

- `HOST` - Listen address (default: localhost)
- `PORT` - Listen port (default: 2019)
- `DISK_MOUNT_PREFIX` - Path prefix for disk monitoring (default: /var/lib/rancher)
- `SCREEN_WIDTH` - Display width in pixels (default: 240)
- `SCREEN_HEIGHT` - Display height in pixels (default: 240)

### Example with custom screen size

```bash
export SCREEN_WIDTH=320
export SCREEN_HEIGHT=240
./pibox-framebuffer
```

Or with Docker:

```bash
sudo docker run -d --privileged -p 2019:2019 \
    -e SCREEN_WIDTH=320 -e SCREEN_HEIGHT=240 \
    --device=/dev/mem --device=/dev/gpiomem --device=/dev/spidev0.0 --device=/dev/spidev0.1 \
    --name pibox-framebuffer ghcr.io/cybermaak/pibox-framebuffer:latest
```

## Usage
### Pull latest image and run container

     sudo docker run -d --privileged  -p 2019:2019 \
        --device=/dev/mem --device=/dev/gpiomem --device=/dev/spidev0.0 --device=/dev/spidev0.1 \
        --name pibox-framebuffer  ghcr.io/cybermaak/pibox-framebuffer:latest

#### Or docker compose
```yaml
version: '3.8'
services:
  pibox-framebuffer:
    image: ghcr.io/cybermaak/pibox-framebuffer:latest
    container_name: pibox-framebuffer
    restart: always
    privileged: true
    environment:
      - SCREEN_WIDTH=240
      - SCREEN_HEIGHT=240
      # - HOST=0.0.0.0  # Uncomment to listen on all interfaces
      # - PORT=2019     # Uncomment to change port
    devices:
      - /dev/mem:/dev/mem
      - /dev/gpiomem:/dev/gpiomem
      - /dev/spidev0.0:/dev/spidev0.0
      - /dev/spidev0.1:/dev/spidev0.1
    ports:
      - "2019:2019"
```

### Drawing an image

`curl -X POST --data-binary @image.png http://localhost:2019/image`

NOTE: Other text and graphics endpoints were supported in old versions, but for the sake of this code's simplicity, we now recommend updating to this version, creating an image using something like the NodeJS [Canvas](https://www.npmjs.com/package/canvas) package, and then then flushing it to the screen using the above endpoint. This new version uses SPI and is far more stable than the framebuffer kernel modules, which can inadvertently redirect console output to the LCD.




## Installing for development
    # Build the binary
    ./go-build.sh

    # Run server
    ./pibox-framebuffer

### Build and run the docker image locally

    sudo ./build.sh
    sudo docker run -d --privileged \
        --device=/dev/mem --device=/dev/gpiomem --device=/dev/spidev0.0 --device=/dev/spidev0.1 \
        -p 2019:2019 --name pibox-framebuffer cybermaak/pibox-framebuffer 


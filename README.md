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

## Usage
### Build and run the docker image

    sudo ./build.sh
    sudo docker run -d --privileged \
        --device=/dev/mem --device=/dev/gpiomem --device=/dev/spidev0.0 --device=/dev/spidev0.1 \
        -p 2019:2019 --name pibox-framebuffer cybermaak/pibox-framebuffer 


### Drawing an image

`curl -X POST --data-binary @image.png http://localhost:2019/image`

NOTE: Other text and graphics endpoints were supported in old versions, but for the sake of this code's simplicity, we now recommend updating to this version, creating an image using something like the NodeJS [Canvas](https://www.npmjs.com/package/canvas) package, and then then flushing it to the screen using the above endpoint. This new version uses SPI and is far more stable than the framebuffer kernel modules, which can inadvertently redirect console output to the LCD.

## Installing for development
    # Build the binary
    ./go-build.sh

    # Run server
    ./pibox-framebuffer

![dockerdown](./logo.webp)

# dockerdown

A Docker-based Nginx server that uses the fancyindex module with custom Markdown rendering and theme support.

## Installation

```sh
git clone https://github.com/phx/dockerdown
sudo mv dockerdown/dockerdown /usr/local/bin/
rm -rf dockerdown
```

## Usage

- Pre-requisite: Docker

```
Usage: ./dockerdown -p <port> -d <directory> [-q]
    -p  Specify the port to expose (default: 8080)
    -d  Specify the directory to mount into the container
    -q  Enable quiet mode (optional)
```

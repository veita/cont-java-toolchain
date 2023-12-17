# Java Build Toolchain


```bash
git clone https://github.com/veita/cont-debian-multiservice debian-multiservice
cd debian-multiservice
./build-image.sh
```

## Building the image

```bash
git clone https://github.com/veita/cont-java-toolchain java-toolchain
cd java-toolchain
./build-image.sh
```

## Running the container

Run the container, e.g. with

```bash
podman run --name java-toolchain --hostname java-toolchain --privileged -it --rm -v=./tmp:/qsk:rw -v=$HOME/.ssh:/root/.ssh:ro localhost/java-toolchain
```

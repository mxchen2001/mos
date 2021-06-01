# MOS (Mike OS)

## Getting Started 
Building the docker image. The Dockerfile that is responsible for docker image is the first Dockerfile located inside `/buildenv`. Simply run

``` bash
$ docker build buildenv -t <docker tag name>

# I used 
$ docker build buildenv -t mos2-buildenv
```

## Running the Container
MacOS or Linux:
```bash
$ docker run --rm -it -v $pwd:/root/env <docker tag name>

# I used 
$ docker run -it -v /Users/mxchen/Local/mos2:/root/env mos2-buildenv
```

Note: I ran into an issue where I had to mannually include the pwd for docker

Windows
```powershell
$ docker run --rm -it -v %cd%:/root/env <docker tag name>

# I used 
$ docker run --rm -it -v %cd%:/root/env mos2-buildenv
```

The options used contains `--rm`, `-it`, `-v`
- `--rm` - Automatically remove the container when it exits
- `-it` -  allocate a pseudo-TTY connected to the container’s stdin; creating an interactive `bash` shell in the container
- `-v` - flag mounts the current working directory into the container

## Running the emulator
Since running `qemu` through native hardware is much easier than docker just run `make qemu` for each of the parts

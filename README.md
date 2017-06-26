# tryitonline/tryitoffline

## Background

This docker image is to allow running <https://tryitonline.net> locally. Here are the image's limitations:

- It is not updated often, so <https://tryitonline.net> is always more up to date. (But see below on how to update individual languages)
- The image as of the time of writing is about **4GB in size**, so it can take some time to download depending on your connection speed
- The image takes about **2 hours to build** (again, depending on your machine spec) - you don't have to build it though, you can download it (as above)
- Since TryItOnline security is based on SELinux, and it is not possible to run SELinux specific commands inside a docker container, SELinux is disabled in this image. This means, that if someone can browse to the web site served by this image, they are a root inside the docker container and can potentially compromise the host. **!!!Do not expose installations based on this image to any non-trusted environment (e.g.: internet)!!!**
- Dyalog APL is not included in the image. If you would like to use Dyalog APL, you'll have to copy the installation rpms into the container and install them with dnf. (See below)

This image was tested to run fine on both Windows (Windows 10) and Linux (Ubuntu 16.04).

## Getting the image

You can build the image yourself. Run in the root of the repo:

```bash
docker build --no-cache=true -t tryitonline/tryitoffline .
```

Or download from docker hub:

```bash
docker pull tryitonline/tryitoffline .
```

## Running the image

First add the following to your hosts file:

```text
127.0.0.1 tryitonline
127.0.0.1 tiorun
```

When you put the host records your computer starts resolving domain names as per the record configured, so tryitonline will resolve to 127.0.0.1. The web server uses the host header to select the site to serve. The host header is what you specify in the domain part off the url, which is in this case "tryitonline"
The image configured to recognize "tryitonline" for the static site "e.g. tryitonline.net" and tiorun for the dynamic part (e.g "tio.run"), this can be changed in the apache configuration (/etc/httpd inside the container). *Note: As of June 2017, tryitonline.net and tio.run were merged to a single site with tryitonline.net redirecting to tio.run*

The hosts file is usually at `C:\Windows\System32\drivers\etc\hosts` on Windows or `/etc/hosts` on Linux.

Then start the container:

```bash
docker run -d --name tiooffline -p 80:80 --add-host arena:127.0.0.1 tryitonline/tryitoffline
```

Now browse to <http://tryitonline>, that's it.

## Maintenance

You already know the below if you are familiar with docker, but if not, here is a few useful commands. This allows you to connect to the container's shell:

```bash
docker exec -it tiooffline /bin/bash
```

To stop the container use:

```bash
docker stop tiooffline
```

To start the container again use:

```bash
docker start tiooffline
```

To remove container use:

```bash
docker container rm -f tiooffline
```

To remove image use:

```bash
docker image rm tryitonline/tryitoffline
```

In the image there are volumes for `/srv` (web sites contents) and `/etc/httpd` (web sites configuration) are defined. You can either use `docker run` switch `-v` to map them where ever you like on the host file system, or use `docker container inspect tiooffline` to see where docker mapped them by default. Please refer to docker documentation for more details. You might want to change httpd configuration and/or sites contents if you want them to be served, say on different ports of `localhost`.

For quick test of all languages you can use:

```bash
tiodryrun
```

inside container shell. (Depending on your hardware it can take around 2 minutes to finish).

## Troubleshooting

It is generally recommended pulling `tryitonline/tryitoffline:tested` from Docker Hub, since it is usually minimally tested. If you build your own image and it does not work (which is most often happens because of network connectivity problems) here are a few ways to diagnose.

You can delete your old container with `docker container rm -f tiooffline` then create a new one without trying to start tryitonline, but just with bash to access the build logs `docker run -it tryitonline/tryitoffline /bin/bash` the logs are then in `/var/log/tioupd`

Another way to diagnose it is to remove the container as above and then run it like this: `docker run -it --name tiooffline -p 80:80 --add-host arena:127.0.0.1 tryitonline/tryitoffline` this will produce some start up output and possibly some errors that could help.


## Updating languages

Some languages updates are tricky, but some languages (listed [here](https://github.com/TryItOnline/tiosetup/tree/master/languages)) can be updated relatively easily from the command line. Run:

```bash
docker exec -it tiooffline /bin/bash
```

to drop into container, then run, for example, to update jelly:

```bash
tiopull jelly
```

Also some languages may be updated by running `dnf update`.

If a new language needs to be added to the image, in might be easier to rebuild the image. That will pull all the languages from [tiosetup](https://github.com/TryItOnline/tiosetup).


## Adding Dyalog APL

If you have Dialog APL installation rpms, you can copy them into your container:

```bash
docker cp linux_64_15.0.29644_unicode.x86_64.rpm tiooffline:/opt/linux_64_15.0.29644_unicode.x86_64.rpm
```

Then drop into the container and install it as usual:

```bash
docker exec -it tiooffline /bin/bash
dnf install /opt/linux_64_15.0.29644_unicode.x86_64.rpm
```

You need to repeat the same process for classic version, if you want both of them running.

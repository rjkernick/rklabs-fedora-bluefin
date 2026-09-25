# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files
COPY cosign.pub /cosign.pub

# Base Image: Bluefin DX (includes libvirt/virt-manager, Docker, Tailscale, distrobox, VS Code)
FROM ghcr.io/ublue-os/bluefin-dx:stable

### IMMUTABLE /opt
## 1Password and Brave install into /opt. On Fedora /opt is a symlink to /var/opt,
## which is not carried over from the image, so make it a real directory in the image.
RUN rm /opt && mkdir /opt

### MODIFICATIONS
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
RUN bootc container lint

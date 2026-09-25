# rklabs-fedora-bluefin

My personal [bootc](https://github.com/bootc-dev/bootc) image: [Bluefin DX](https://projectbluefin.io/) with a few extra host-level packages. Built daily with GitHub Actions and signed with cosign.

## What's included

Everything in `ghcr.io/ublue-os/bluefin-dx:stable` (GNOME, Homebrew, distrobox, Tailscale, Docker, libvirt/virt-manager, VS Code), plus:

| Addition | Why it's in the image |
|---|---|
| **1Password** + **1Password CLI** | Desktop app, SSH agent and `op`; browser integration needs a native (non-Flatpak) browser |
| **Brave** (RPM) | Native browser so 1Password browser integration works |
| `tailscaled` enabled | Tailscale ready on first boot |

`/opt` is made immutable in the image so 1Password and Brave (which install into `/opt`) survive deployment.

## Install

From any Fedora Atomic / Universal Blue system:

1. Remove layered packages that the image already provides (check with `rpm-ostree status`):
   ```bash
   sudo rpm-ostree reset
   ```
2. Switch to this image and reboot:
   ```bash
   sudo bootc switch ghcr.io/rjkernick/rklabs-fedora-bluefin:latest
   systemctl reboot
   ```
3. Add your user to the `libvirt`, `docker` and related groups, then log out and back in:
   ```bash
   ujust dx-group
   ```

Rolling back: pick the previous deployment in the boot menu, or run `sudo rpm-ostree rollback`.

## Updates

- The image rebuilds every day at 10:05 UTC, on every push to `main`, and on demand from the Actions tab.
- Each build pulls the current `bluefin-dx:stable` and the latest 1Password and Brave releases.
- Installed systems download and stage updates automatically; they apply on the next reboot. Run `ujust update` to update right away.

## Verify the signature

```bash
cosign verify --key cosign.pub ghcr.io/rjkernick/rklabs-fedora-bluefin:latest
```

## Repository layout

| Path | Purpose |
|---|---|
| [`Containerfile`](Containerfile) | Base image and build steps |
| [`build_files/build.sh`](build_files/build.sh) | Package installs and service setup |
| [`system_files/`](system_files) | Files copied into the image as-is (`etc/`, `usr/`) |
| [`image-template.env`](image-template.env) | Image name and metadata used by the Justfile and CI |
| [`.github/workflows/build.yml`](.github/workflows/build.yml) | Build, push and sign |

Rechunking is disabled in CI: the Bluefin base is already chunked upstream, and rechunking the full image runs the GitHub runner out of disk space.

## Building locally

Requires `just` and `podman`:

```bash
just build
```

See the [`Justfile`](Justfile) for VM and ISO build recipes.

## Credits

Based on Universal Blue's [image-template](https://github.com/ublue-os/image-template). See the [Universal Blue docs](https://docs.projectbluefin.io/) and [bootc docs](https://bootc-dev.github.io/bootc/) for more.

## License

The build files in this repository are licensed under [Apache 2.0](LICENSE). Software included in the built image is covered by its own licenses.

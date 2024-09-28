# easyroam-linux
Setup eduroam with easyroam on Fedora Atomic Desktops. Forked from: https://github.com/jahtz/easyroam-linux

## Motivation (see original [motivation](https://github.com/jahtz/easyroam-linux?tab=readme-ov-file#motivation))
German universities (as of the time of writing) are switching from the official eduroam client to [easyroam](https://www.easyroam.de) by [DFN](https://www.dfn.de/) in october 2024.
Since I needed to set up Wi-Fi on my Fedora Silverblue notebook, I tried to follow their guide but quickly realized that they only officially provide a .deb client for Debian-based distributions and porting the file with [alien](https://joeyh.name/code/alien/) did not work. 

I stumbled upon this repository from [jahtz](https://github.com/jahtz) that simplified the [official guide](https://doku.tid.dfn.de/de:eduroam:easyroam#installation_der_easyroam_app_auf_linux_geraeten_network_manager) significantly. Since I'm on [Fedora Atomic](https://fedoraproject.org/atomic-desktops/), I would have to layer the `openssl` with `rpm-ostree` to be able to use the script. Since I don't want to layer any packages on top of the base image, I decided to use [toolbox](https://github.com/containers/toolbox). Thus I had to split the original script in two, one for `openssl` and one for `nmcli`.

I've only tested the direct setup on Fedora Silverblue 40 with NetworkManager.

**If you are using a "regular" linux distribution with a package manager, please consider using the original script from [jahtz](https://github.com/jahtz/easyroam-linux)!**

## Usage
### Get certificate
1. Open https://www.easyroam.de
2. Search your university and log in.
3. Go to `Generate profile`.
4. Select `manual options`, select `PKCS12` and enter your device name.
5. Download the file by clicking on the `Generate profile`-Button.

### Install toolbox container (needed for openssl)
1. If you don't have a toolbox container created:
   ```
   toolbox create
   ```
   and type 'y' to confirm installation
2. To enter, type:
   ```
   toolbox enter
   ```
   To exit, type:
   ```
   toolbox exit
   ```

### Fedora Atomic Desktop (e.g. Silverblue) with NetworkManger
1. Download the **certificate** script:
    ```
    curl -o easyroam_cert.sh https://raw.githubusercontent.com/C-3PK/easyroam-linux/main/easyroam_cert.sh
    ```
2. Make it executable:
    ```
    chmod +x easyroam_cert.sh
    ```
3. Run setup (**INSIDE** toolbox-container):
    ```
    ./easyroam_cert.sh
    ```
4. If you want to delete the generated config remove _/etc/NetworkManager/system-connections/easyroam.nmconnection_ or run:
    ```
    nmcli connection delete easyroam
    ```
5. Download the **NetworkManager** script:
   ```
   curl -o easyroam_nm.sh https://raw.githubusercontent.com/C-3PK/easyroam-linux/main/easyroam_nm.sh
   ```
6. Make it executable:
   ```
    chmod +x easyroam_nm.sh
    ```
3. Run setup (**OUTSIDE** toolbox-container):
    ```
    ./easyroam_nm.sh
    ```
[Original Apache 2.0 Licence](https://github.com/jahtz/easyroam-linux/blob/main/LICENSE)

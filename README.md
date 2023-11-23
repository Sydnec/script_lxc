# LXC Container Creation Script
### Version 1.1 as of 09/23/23


## Description

This Bash script automates the creation of an LXC (Linux Containers) container, performs various configurations, and provides information for connecting to the container via SSH.

---

## Usage

```bash
./script_name.sh -n <container_name> -d <distribution> -r <release> -a <arch> -u <username> -p <password> [-h]
```
---

## Utilisation

```
./script_name.sh -n <container_name> -d <distribution> -r <release> -a <arch> -u <username> -p <password> [-h]
    -n: Container name
    -d: Distribution (default: debian)
    -r: Distribution release (default: bullseye)
    -a: Distribution architecture (default: amd64)
    -u: Username for the container
    -p: Password for the new user
    -h: Display help message
```
---
## Example

```bash
./script_name.sh -n my_container -d debian -r bullseye -a amd64 -u user -p password
```
---

## Author

Simon Bourlier

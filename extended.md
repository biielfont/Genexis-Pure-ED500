## Home

## Purpose and Scope

This wiki documents the **Genexis Pure ED500** router modification project, which enables users to gain complete **root access** to their ISP-locked device and **remove remote management backdoors**. The device, distributed by Adamo and other ISPs, runs a modified **OpenWrt** firmware with **Iopsys** customizations and the **JUCI** web interface.

This documentation covers:

* **Root access procedures** via UART and bootloader manipulation (see **Gaining Root Access**)
* **ISP backdoor removal** including TR-069/CWMP remote management systems (see **Removing ISP Backdoors**)
* **Password management** understanding and credential modification (see **Password and User Management**)
* **Recovery procedures** for bricked or misconfigured devices (see **Recovery Procedures**)
* **Firmware management** including version information and flashing procedures (see **Firmware Management**)

For hardware specifications and boot process details, see **Device Overview**.

---

## Project Overview

The Genexis Pure ED500 is a **MIPS 24kc-based OpenWrt router** that has been locked down by ISPs for remote management. This project provides a comprehensive methodology for:

* **Bypassing authentication** through hardware-level **UART access** and **U-Boot** bootloader manipulation
* **Gaining persistent root access** by modifying `/etc/preinit` to provide a fully-initialized root shell
* **Understanding the password synchronization system** between UCI configuration files and system authentication
* **Removing TR-069 backdoors** permanently from both UBIFS firmware banks
* **Recovering from firmware failures** using documented TFTP and UART-based recovery procedures

The approach documented here achieves complete user control without requiring firmware recompilation or custom firmware installation. All modifications work within the existing **OpenWrt/Iopsys** environment.

---

## System Architecture Overview

The following diagram illustrates the major system components and their relationships within the Genexis Pure ED500 device:



**System Architecture: Major Components and File Paths**

The system operates in distinct layers from **hardware** through to **user interfaces**, with ISP control mechanisms integrated throughout the boot and service layers.

---

## Critical System Components

The following table maps key system functionality to specific files and components in the codebase:

| Component | File Path | Purpose | Modified in Project |
| :--- | :--- | :--- | :--- |
| **Boot Configuration** | `bootargs` (U-Boot variable) | Kernel boot parameters, controls init process | **Yes** - for initial access |
| **Early Init Hook** | `/etc/preinit` | First userspace script, executes before full init | **Yes** - adds `exec /bin/sh` |
| **System Init** | `/sbin/init` | Primary init process, starts all services | No |
| **Password Sync** | `/etc/init.d/passwords` | Syncs UCI passwords to `/etc/shadow`, self-cleaning | No |
| **User Definitions** | `/etc/config/users` | UCI configuration for user accounts | No |
| **Password Config** | `/etc/config/passwords` | UCI configuration for password hashes | No |
| **System Auth** | `/etc/shadow` | System password hashes (root, admin, support, user) | **Yes** - via `passwd` command |
| **User Accounts** | `/etc/passwd` | System user account database | **Yes** - via `passwd` command |
| **TR-069 Control** | `/usr/sbin/icwmp` | Bash script controlling TR-069 client | **Yes** - renamed/deleted |
| **TR-069 Client** | `/usr/sbin/icwmpd` | Main TR-069/CWMP client daemon binary | **Yes** - renamed/deleted |
| **STUN Daemon** | `/usr/sbin/icwmp_stund` | STUN daemon for NAT traversal to ACS server | **Yes** - renamed/deleted |
| **TR-069 Config** | `/etc/config/cwmp` | UCI configuration for TR-069 system | **Modified** by removal |
| **Primary Firmware** | `rootfs_0` (UBI volume) | Active firmware bank (UBIFS) | **Modified** for persistence |
| **Secondary Firmware** | `rootfs_1` (UBI volume) | Alternate firmware bank (UBIFS) | **Modified** for persistence |
| **Removal Script** | `scripts/cleanscript_persistant.sh` | Permanently removes backdoors from both banks | Provided in repo |

---

## Access Control Flow

This diagram shows how user access progresses from initial ISP-locked state to full user control, mapping each stage to specific code entities:



**Access Control Flow: From ISP Lock to User Control**

This flow demonstrates the complete process of gaining control over the device, with each node referencing specific files, commands, or system components that must be modified or executed.

---

## Key System Files Reference

### Authentication and User Management

The password synchronization system operates through a chain of files:

* `/etc/config/users` - Defines user accounts (**root, admin, support, user**) with UCI format
* `/etc/config/passwords` - Contains password hashes in UCI format, processed at boot
* `/etc/init.d/passwords` - Init script that reads UCI passwords, applies them via `passwd` command, then **deletes UCI entries** to prevent overwriting
* `/etc/passwd` - Standard Linux user account database
* `/etc/shadow` - Standard Linux password hash storage

The critical behavior: `/etc/init.d/passwords` executes during boot, syncs UCI passwords to `/etc/shadow`, then runs `uci delete passwords.admin.password` to prevent persistent overwriting. This means **password changes made via `passwd` command persist across reboots.**

### ISP Backdoor Components

The **TR-069** remote management system consists of:

* `/usr/sbin/icwmp` - Bash script that launches and controls the TR-069 client (see **TR-069 Components**)
* `/usr/sbin/icwmpd` - Main TR-069/CWMP client daemon binary that communicates with ACS server
* `/usr/sbin/icwmp_stund` - STUN daemon enabling NAT traversal for ISP to reach device
* `/etc/config/cwmp` - UCI configuration file for TR-069 parameters
* `/usr/share/icwmp/functions/*` - CWMP operation handlers

These components connect to `acs.adamo.es`, the ISP's **Auto Configuration Server (ACS)**, enabling remote firmware updates, configuration changes, and system access.

### Boot and Initialization

The boot sequence involves:

* **U-Boot** loads from `/boot/uboot.img` on NAND flash (1MB partition)
* `bootargs` U-Boot environment variable specifies: `console=ttyLTQ0,115200 root=ubi0:rootfs_0 ubi.mtd=ubi,0,30 rootfstype=ubifs`
* **Kernel** boots from `rootfs_0` or `rootfs_1` UBI volume
* `/etc/preinit` executes as first userspace script
* `/sbin/init` starts the full init system and all services

Modifying `/etc/preinit` to add `exec /bin/sh` at the end provides a **persistent root shell** after all services initialize but before control returns to normal operation.

---

## Getting Started

To gain control of your Genexis Pure ED500:

1.  **Connect UART hardware** - Required for initial access (see **UART Connection Setup**)
2.  **Interrupt U-Boot and boot to minimal shell** - Modify `bootargs` to `init=/bin/sh` (see **U-Boot Bootargs Modification**)
3.  **Make filesystem writable and modify /etc/preinit** - Add `exec /bin/sh` for persistent access (see **Persistent Root Shell via Preinit**)
4.  **Change passwords** - Use `passwd` command for **root, admin, and support** users (see **Changing Passwords**)
5.  **Remove TR-069 backdoor** - Rename binaries and run `cleanscript_persistant.sh` (see **Removing ISP Backdoors**)
6.  *Optional:* **Recover from issues** - Use documented TFTP procedures if needed (see **Recovery Procedures**)

For complete firmware version information and ISP-specific customizations, see **Firmware Management**.

For advanced usage including package installation and custom services, see **Advanced Topics**.

---

## Important Notes

### SSH Access Configuration

The device runs an SSH server on **port 22666** (not the standard port 22). Only the **root** user can access SSH because other users (admin, support, user) do not have home directories configured, which prevents SSH authentication even with correct passwords.

### Dual-Bank Persistence

The device uses a **dual-bank UBIFS system** with `rootfs_0` and `rootfs_1` volumes. Changes must be applied to **both banks** to survive factory resets or firmware switches. The `cleanscript_persistant.sh` script handles this automatically for backdoor removal.

### WAN Connection Warning

When connected to WAN with **TR-069** still active, the ISP's ACS server can automatically reflash the firmware, undoing modifications. Always **disable or remove TR-069 components** before connecting to ISP network after gaining root access.

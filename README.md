# Windows Maintenance Toolkit

A collection of interactive Windows batch utilities for cleanup, diagnostics, repair, network maintenance, OneDrive removal, WinSxS servicing, and Windows 11 tweaks.

> **Current UI language:** Turkish. Documentation is available in English and Turkish.

## Included tools

| Tool | Purpose | Administrator |
|---|---|---|
| `src/clean-amd-cache.bat` | Cleans AMD/DirectX/Vulkan shader cache locations. | Required |
| `src/clean-network-optimization.bat` | Network information, DNS tools, proxy reset, adapter reset, TCP/IP repair and tuning. | Required |
| `src/clean-onedrive.bat` | Removes OneDrive components; optionally removes the local OneDrive user folder. | Required |
| `src/clean-pc.bat` | Interactive Windows cleanup with automatic, manual and preview modes. | Required |
| `src/clean-winsxs.bat` | DISM/SFC based Windows component-store analysis, repair and cleanup. | Required |
| `src/cleanliness-scan.bat` | Read-only cleanup scan that generates HTML/CSV reports. | Required for full system coverage |
| `src/manage-right-click-menu.bat` | Switches between the classic and default Windows 11 context menu. | Not required |

## Requirements

- Windows 10 or Windows 11 (some features are Windows 11 specific)
- Windows PowerShell 5.1 for PowerShell-backed operations
- Administrator privileges for tools marked **Required** above
- UTF-8 capable Windows console

## Usage

1. Download or clone the repository.
2. Review the script in the `src/` directory that you intend to run.
3. For tools that require elevation, right-click the relevant `.bat` file in `src/` and choose **Run as administrator**.
4. Follow the interactive menu and read warnings before confirming destructive actions.

## Important safety notes

These scripts can modify system configuration or permanently delete data. In particular:

- `src/clean-onedrive.bat` includes an option that permanently deletes the detected local OneDrive user folder.
- `src/clean-winsxs.bat` includes DISM `/ResetBase`; after this operation, installed Windows updates cannot be uninstalled.
- `src/clean-network-optimization.bat` can reset proxy, TCP/IP, Winsock, DNS and network adapter settings. Custom corporate/VPN/static-network settings may need to be reconfigured.
- `src/clean-pc.bat` can delete temporary/update/cache data and empty the Recycle Bin.

Create an appropriate backup or restore point before using maintenance tools on important systems. Review the source before execution.

## Versioning

Current public release: **1.0.0**

The version displayed by each utility is defined in its own `VERSION` variable under `src/`.

## Security

The repository contains plain-text Batch/PowerShell logic and does not download or execute remote payloads. Some operations invoke built-in Windows tools such as `DISM`, `SFC`, `netsh`, `reg`, and Windows PowerShell.

See [SECURITY.md](SECURITY.md) for reporting security issues.

## Turkish documentation

See [README.tr-TR.md](README.tr-TR.md).

## License

MIT License. See [LICENSE](LICENSE).

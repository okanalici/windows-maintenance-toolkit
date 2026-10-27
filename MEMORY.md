# MEMORY.md

## Project status

- Last reviewed: 2026-10-27
- Scope: Seven Windows batch utilities in `src/`
- Visible script version: `1.0.0`
- External dependencies: None. Some scripts invoke Windows PowerShell and
  built-in Windows utilities.
- Git repository: Present at the repository root.
- `src/clean-network-optimization.bat`: Saves the current user's proxy registry
  settings to `%TEMP%\windows_maintenance_proxy_backup.reg` before resetting
  them. The main menu has no backup-deletion option.
- All seven utilities use Turkish UI text and a consistent ANSI-colored console
  presentation. Existing deletion/removal choices remain intact; the read-only
  scan tool does not gain deletion behavior.

## Shared technical structure

The scripts generally follow this flow:

1. Enable the UTF-8 console code page (`chcp 65001`).
2. Prepare ANSI colors and the shared console appearance.
3. Check administrator privileges when required.
4. Accept a menu selection, perform the requested operation, and report its
   result.
5. Keep temporary variables within the `setlocal` scope on exit.

The UI text is Turkish. Some source files previously had Turkish-character
encoding issues, so verify the actual encoding and console output whenever UI
text changes.

## Tool behavior

| File | Administrator | Effect summary |
| --- | --- | --- |
| `src/clean-pc.bat` | Yes | Cleans Windows and user temporary areas, selected maintenance remnants, and the Recycle Bin. Provides preview, manual, and automatic modes. |
| `src/clean-winsxs.bat` | Yes | Performs DISM analysis/servicing, SFC, and WinSxS cleanup. `ResetBase` can prevent update rollback. |
| `src/clean-network-optimization.bat` | Yes | Can operate on DNS, proxy, TCP/IP, Winsock, and active network adapters. Stores its proxy backup under `%TEMP%`. |
| `src/clean-amd-cache.bat` | Yes | Selectively removes AMD and graphics-API shader-cache folders. |
| `src/clean-onedrive.bat` | Yes | Stops OneDrive and can remove application, policy, and task remnants; its second option can also remove the local user folder. |
| `src/cleanliness-scan.bat` | Yes | Scans without deleting files using an embedded PowerShell payload; writes HTML/CSV reports and opens the HTML report. |
| `src/manage-right-click-menu.bat` | No | Changes only the current user's (`HKCU`) Windows 11 context-menu setting and immediately restarts Explorer after a successful change. |

## Risky operation summary

- Deletion commands (`del`, `rd`, `rmdir`) primarily target fixed Windows
  cache/maintenance paths; path validation is required before adding a target.
- The OneDrive removal flows that retain files and delete files are separate.
  Do not weaken the warning for the file-deleting flow.
- The WinSxS `ResetBase` option may have irreversible consequences; preserve
  its explanation and confirmation.
- The network tool changes DNS/proxy/Winsock/TCP-IP settings and can briefly
  disable and re-enable adapters.
- The context-menu tool can write below
  `HKCU\Software\Classes\CLSID\...`; it must not use `HKLM`.
- The scripts use embedded PowerShell/`Add-Type` helper code for the shared
  console-font configuration. Failures in that helper must not stop the primary
  workflow.

## Maintenance notes

- When adding a feature, update the related menu choice, action label, and
  success/error messages together.
- When adding an operation that needs elevation, review both its comment and
  privilege check.
- Do not add deletion commands to the read-only scan tool; keep reporting and
  cleanup responsibilities separate.
- Do not leave temporary output in the repository. Temporary files such as the
  network tool's proxy backup belong under `%TEMP%`.
- During validation, statically inspect risky commands first. When possible,
  test each menu option in a controlled Windows virtual machine.

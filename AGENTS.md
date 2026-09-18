# AGENTS.md

## Project overview

This repository provides interactive `.bat` utilities for Windows maintenance,
cleanup, diagnostics, and configuration. The tools run directly in Windows
Command Prompt and have no build system, package manager, or external
dependencies.

## File map

All executable batch scripts are stored in `src/`:

- `src/clean-pc.bat`: Cleans temporary files, Windows Update downloads, error
  reports, Prefetch, the Recycle Bin, and similar maintenance locations. It
  supports automatic, manual, and preview modes.
- `src/clean-winsxs.bat`: Provides DISM/SFC analysis, servicing, and
  `ResetBase` options for the Windows image and WinSxS component store.
- `src/clean-network-optimization.bat`: Menus for network information,
  connectivity tests, DNS/proxy tools, TCP/IP, Winsock, and adapter resets.
- `src/clean-amd-cache.bat`: Selectively cleans AMD, DirectX, Vulkan, and
  OpenGL shader caches in user and system profiles.
- `src/clean-onedrive.bat`: Removes OneDrive while offering options to retain
  user files or also delete the local OneDrive folder.
- `src/cleanliness-scan.bat`: Reports cleanup candidates without deleting
  files through an embedded PowerShell scan. It supports quick, standard,
  deep, and custom scan modes.
- `src/manage-right-click-menu.bat`: Switches the current user's Windows 11
  context menu between classic and default views.

## Running and validation

- Run the scripts as `.bat` files on Windows 10 or Windows 11.
- Scripts that require administrator privileges perform their own elevation
  checks. Do not force an operation when it fails in a non-administrator
  session.
- After a change, at minimum review the syntax of the affected script and run
  the affected menu flow in a Windows test environment.
- Preserve the embedded PowerShell payload start/end markers in
  `src/cleanliness-scan.bat`; its payload extraction depends on them.
- When Windows is unavailable, do not claim that `.bat` files were executed.
  Perform static checks instead and report this limitation.

## Change rules

- Preserve the existing menus, shared user interface, and error-handling style.
- Do not change the scripts' initial `chcp 65001`, `setlocal EnableExtensions`,
  version, or console-size settings unless necessary.
- Preserve Windows `CRLF` line endings in `.bat` files. Mixed `LF` and `CRLF`
  endings can cause `cmd.exe` blocks to parse incorrectly and execute commands
  piecemeal.
- Use explicit, safe command targets. Before adding wildcards or broad deletion
  operations, verify the target path.
- Add a clear warning and confirmation flow to operations that affect user data.
- For registry changes, explicitly state the scope (`HKCU` or `HKLM`) and make
  the rollback path visible in menu text or documentation.
- Do not silently automate actions with limited rollback or system-wide impact,
  including `ResetBase`, deletion of the local OneDrive folder, Explorer
  restarts, or Winsock/IP resets.
- When adding a script, update this file's map and the inventory in `MEMORY.md`.
- Use the existing lowercase, hyphen-separated file naming convention.

## Security notes

This project changes real system state. Use a virtual machine or restore point
for testing. Before modifying `del`, `rd`/`rmdir`, `reg add`, `taskkill`,
`Dism /ResetBase`, `Remove-AppxPackage`, or network-reset commands, inspect the
target, required privileges, and failure handling. Do not write temporary files,
such as proxy backups, into the repository directory.

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

- Run `.bat` files with `cmd.exe` on Windows 10 or Windows 11, with Windows
  PowerShell 5.1 and a UTF-8/ANSI-capable console. No dependency install is needed.
- All scripts except `src/manage-right-click-menu.bat` require administrator
  privileges, including the scan tool. They check elevation themselves; do not
  bypass a failed check.
- There is no automated test/build runner. For documentation-only changes, run
  `git diff --check` from the repository root in PowerShell or Command Prompt;
  Git is required. This checks whitespace, not Batch syntax or runtime behavior.
- For scan-payload changes, also run this read-only syntax check from the
  repository root in Windows PowerShell 5.1; it parses but never runs the payload:

  ```powershell
  $raw = [IO.File]::ReadAllText((Join-Path $PWD 'src/cleanliness-scan.bat'), [Text.Encoding]::UTF8)
  $begin = '### POWERSHELL_PAYLOAD_BEGIN ###'
  $end = '### POWERSHELL_PAYLOAD_END ###'
  $i = $raw.IndexOf($begin)
  if ($i -lt 0) { throw 'Payload start marker missing' }
  $i += $begin.Length
  $j = $raw.IndexOf($end, $i)
  if ($j -lt 0) { throw 'Payload end marker missing' }
  $tokens = $null; $errors = $null
  $null = [Management.Automation.Language.Parser]::ParseInput($raw.Substring($i, $j - $i), [ref]$tokens, [ref]$errors)
  if ($errors.Count) { $errors; exit 1 }
  ```

- After script changes, review the affected Batch syntax and test the affected
  menu flow in a disposable Windows VM with the required privileges. Do not run
  maintenance actions on the host as a validation shortcut.
- Preserve the exact `### POWERSHELL_PAYLOAD_BEGIN ###` and
  `### POWERSHELL_PAYLOAD_END ###` markers and the Batch exit before the payload
  in `src/cleanliness-scan.bat`; extraction depends on them.
- Keep the scan non-destructive. It still writes HTML/CSV reports under
  `Bilgisayar-Tarama-Raporu` on the Desktop (falling back to the working directory,
  then LOCALAPPDATA/TEMP when needed) and opens the HTML report; running it is
  not a side-effect-free syntax check.
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

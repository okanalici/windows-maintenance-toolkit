# Security Policy

## Supported version

The current supported release is `1.0.x`.

## Reporting a vulnerability

Please use GitHub's private security advisory feature when possible. Avoid publishing exploit details in a public issue before a fix is available.

When reporting a problem, include:

- Affected script and version
- Windows version/build
- Exact menu option or operation
- Expected and actual behavior
- Relevant console output with personal paths, usernames, tokens and network secrets removed

## Execution model

These utilities use Windows Batch and Windows PowerShell and may invoke built-in Windows administration tools. Review the source before running elevated scripts.

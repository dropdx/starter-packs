# 🏗️ Architecture of the Ubuntu Starter Pack

This document details the internal organization of the `dropdx` Ubuntu Starter Pack. Understanding this architecture is key to both contributing to this starter pack and effectively utilizing its components with `dropdx`.

The core principle behind this structure is to clearly separate **development-related files** (those used for managing and building the starter pack itself) from the **deployable configuration files** (the actual dotfiles and scripts meant to be placed on a user's system).

---

## Directory Structure

```bash
starters/ubuntu/
├── README.md               # [DEV FILE] Overview of the Ubuntu Starter Pack.
├── package.json            # [DEV FILE] For managing this starter pack's internal Node.js dependencies or scripts.
├── tsconfig.json           # [DEV FILE] TypeScript configuration for any internal TS code (e.g., build scripts).
├── tsconfig.starter.json   # [DEV FILE] Specific TypeScript config variant for this starter pack.
├── src/                    # [DEV FILE - OPTIONAL] Source code for generating or managing payload content.
│   └── ...
└── payload/                # [DEPLOYABLE CONTENT] Contains all the files to be deployed by dropdx.
├── shell/                  # All shell-related configurations (aliases, functions, completions).
│   ├── aliases/            # Directory for individual alias files (e.g., git.sh, dev.sh).
│   ├── aliases.sh          # Orchestrator script to load aliases from aliases/.
|   ├── functions/          # Directory for individual shell functions
|   └── functions.sh        # Orchestrator script to load functions from functions/.
├── git/                    # Git-specific configurations.
│   └── gitmessage.txt
└── ...                     # Other configurations (e.g., VS Code, Docker, terminal emulators).
```

## Explanation of Sections

### `starters/ubuntu/` (Root - Development Files)

The files directly within the `starters/ubuntu/` directory are primarily for **managing and developing this specific starter pack**. They are not directly deployed by `dropdx` to a user's system, but rather aid in maintaining the starter pack's source code, dependencies, or build processes (if any).

* **`README.md`**: Provides a high-level overview and deployment instructions for the **end-user** of this Ubuntu starter pack.
* **`package.json`**: Used for defining npm scripts, development dependencies, and metadata specific to this starter pack's internal tooling (e.g., running linters, tests, or build steps for the starter pack itself).
* **`tsconfig*.json`**: If this starter pack utilizes TypeScript for any internal scripts or automation, these files configure the TypeScript compiler.
* **`src/` (Optional)**: If the `payload/` content is generated or managed by source code (e.g., a complex provisioning script written in a high-level language), that source code would reside here.

### `payload/` (Deployable Content)

This directory is the core of the starter pack's functionality. All files and directories within `payload/` are intended to be copied or symlinked by `dropdx` to the user's `$HOME` directory or relevant system configuration paths. These are the files that directly customize the user's environment.

* **`shell/`**: Contains all shell configuration files, structured to support Bash, Zsh, and POSIX-compliant common scripts. Its `init.sh` acts as the primary entry point for sourcing.

---

This architecture ensures a clean separation between the "developer experience" of maintaining the `dropdx` starter pack and the "user experience" of deploying and utilizing the generated configurations.

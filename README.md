# FoundryVTT Docker

This repository provides a Dockerized environment for [Foundry Virtual Tabletop (FoundryVTT)](https://foundryvtt.com/), a powerful and flexible platform for running and managing tabletop RPG games online.

## Features

- Automated extraction and setup of FoundryVTT from provided zip files
- Isolated and reproducible environment for running FoundryVTT
- Easy deployment using Docker

## Getting Started

### Prerequisites

- [Docker](https://www.docker.com/get-started) installed on your system
- A valid FoundryVTT zip file (downloaded from your FoundryVTT account)

### Preparing the Zip Files

1. **Naming Convention:**  
    Place your FoundryVTT zip files in a directory named `versions` at the root of this repository.  
    The zip files must be named in the format:  
    ```
    FoundryVTT-<version>.zip
    ```
    For example:  
    ```
    FoundryVTT-11.307.zip
    FoundryVTT-10.291.zip
    ```

2. **Directory Structure Example:**
    ```
    .
    ├── Dockerfile
    ├── unzip-version.sh
    ├── versions/
    │   ├── FoundryVTT-11.307.zip
    │   └── FoundryVTT-10.291.zip
    ```

### Build the Docker Image

```sh
docker build -t foundryvtt-docker .
```

You can specify a version at build time (defaults to `latest`):
```sh
docker build --build-arg VERSION=11.307 -t foundryvtt-docker .
```

### Run FoundryVTT in Docker

```sh
docker run -it --rm -p 30000:30000 -v /your/data/path:/dev/foundry/data foundryvtt-docker
```

This maps the FoundryVTT data directory to your host for persistence.

## How It Works

- The `unzip-version.sh` script selects and extracts the appropriate FoundryVTT zip file from the `versions` directory based on the `VERSION` build argument.
- The extracted application is copied into the final Docker image and started with Node.js.

## Customization

- To use a different FoundryVTT version, add the corresponding zip file to the `versions` directory and specify the version during build.
- Modify the `Dockerfile` to install additional dependencies if needed.

---

*For more information about FoundryVTT, visit the [official website](https://foundryvtt.com/).*

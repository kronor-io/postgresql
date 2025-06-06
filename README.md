# Custom PostgreSQL 17 Builds

This repository contains GitHub Actions workflows for building custom PostgreSQL 17 packages compiled with Clang 18 for Ubuntu 24.04 LTS (Noble Numbat).

## Features

- Latest PostgreSQL 17 releases
- 32Kb page blocksize
- Debian packages (.deb) for easy installation
- Personal Package Archive (PPA) hosted on GitHub Pages
- Automatic monthly builds to incorporate latest PostgreSQL minor releases

## How to Use the PPA

### Add the Repository

```bash
curl -s --compressed "https://kronor-io.github.io/postgresql/KEY.gpg" | gpg --dearmor | tee /etc/apt/trusted.gpg.d/kronor_postgresql.gpg >/dev/null
curl -s --compressed -o /etc/apt/sources.list.d/kronor_postgresql.list "https://kronor-io.github.io/postgresql/kronor_postgresql.list"
```

### Update and Install

```bash
sudo apt update
sudo apt install postgresql-17
```

## Manual Build Trigger

You can manually trigger a build in the GitHub Actions tab to build a specific PostgreSQL version.

## Project Structure

```
.
├── .github/workflows/    # GitHub Actions workflow configurations
├── scripts/              # Build and repository management scripts
└── README.md             # This documentation file
```

## Customization

To customize the build process:

1. Modify `.github/workflows/build-postgres.yml` to change build parameters
2. Adjust compiler flags in the "Set up CC and CXX environment variables" step

## References

- [Percona Blog: How to create PostgreSQL custom builds and Debian packages](https://www.percona.com/blog/how-to-create-postgresql-custom-builds-and-debian-packages/)
- [GitHub-hosted PPA tutorial](https://assafmo.github.io/2019/05/02/ppa-repo-hosted-on-github.html)
- [PostgreSQL Official Documentation](https://www.postgresql.org/docs/)

## License

The packaging scripts in this repository are licensed under MIT license. PostgreSQL itself is licensed under the [PostgreSQL License](https://www.postgresql.org/about/licence/).
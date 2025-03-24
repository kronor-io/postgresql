#!/bin/bash
set -e

# This script updates the PPA repository with the newly built packages
# Based on https://assafmo.github.io/2019/05/02/ppa-repo-hosted-on-github.html

POSTGRES_VERSION=$1
CODENAME="noble"  # Ubuntu 24.04 codename
ARCH="amd64"      # Architecture for the packages
REPO_ROOT="dist"  # Where the repository will be created
KEY_NAME="postgres-custom-ppa"

# Create GPG key if it doesn't exist
if [ ! -f "private-key.gpg" ]; then
    echo "Generating GPG key for signing packages..."
    cat > key-config <<EOF
    %echo Generating a basic OpenPGP key
    Key-Type: RSA
    Key-Length: 4096
    Name-Real: PostgreSQL Custom PPA
    Name-Email: postgres-custom@example.com
    Expire-Date: 0
    %no-ask-passphrase
    %no-protection
    %commit
    %echo Done
EOF
    gpg --batch --gen-key key-config
    rm key-config
    gpg --export --armor postgres-custom@example.com > ${REPO_ROOT}/KEY.gpg
    gpg --export-secret-keys --armor postgres-custom@example.com > private-key.gpg
fi

# Import the key if we're in CI
if [ -n "$GITHUB_ACTIONS" ]; then
    if [ -f "private-key.gpg" ]; then
        gpg --import private-key.gpg
    else
        echo "Warning: No GPG key found for signing packages"
        exit 1
    fi
fi

# Create repository structure
mkdir -p ${REPO_ROOT}/{conf,deb}

# Create the repository configuration
cat > ${REPO_ROOT}/conf/distributions <<EOF
Codename: ${CODENAME}
Components: main
Architectures: ${ARCH} source
SignWith: ${KEY_NAME}
EOF

# Add packages to the repository
for deb in ${REPO_ROOT}/deb/*.deb; do
    if [ -f "$deb" ]; then
        reprepro -b ${REPO_ROOT} includedeb ${CODENAME} "$deb"
    fi
done

# Create a simple index page
cat > ${REPO_ROOT}/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>PostgreSQL ${POSTGRES_VERSION} Custom PPA</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; max-width: 800px; margin: 0 auto; padding: 20px; }
        h1 { color: #336791; }
        code { background-color: #f4f4f4; padding: 2px 4px; border-radius: 3px; }
    </style>
</head>
<body>
    <h1>PostgreSQL ${POSTGRES_VERSION} Custom PPA</h1>
    <p>This PPA contains custom builds of PostgreSQL ${POSTGRES_VERSION} compiled with clang-18 for Ubuntu 24.04 (Noble).</p>
    
    <h2>How to use this PPA</h2>
    <p>Add the repository to your system:</p>
    <pre><code>sudo sh -c 'echo "deb https://yourusername.github.io/postgres ${CODENAME} main" > /etc/apt/sources.list.d/postgres-custom-ppa.list'</code></pre>
    
    <p>Add the repository key:</p>
    <pre><code>wget -qO- https://yourusername.github.io/postgres/KEY.gpg | sudo apt-key add -</code></pre>
    
    <p>Update and install packages:</p>
    <pre><code>sudo apt update
sudo apt install postgresql-17</code></pre>

    <h2>Available Packages</h2>
    <ul>
EOF

# List all packages in the HTML
for deb in ${REPO_ROOT}/pool/main/p/postgresql/*.deb; do
    if [ -f "$deb" ]; then
        PKG_NAME=$(dpkg-deb -f "$deb" Package)
        PKG_VERSION=$(dpkg-deb -f "$deb" Version)
        echo "        <li>${PKG_NAME} - ${PKG_VERSION}</li>" >> ${REPO_ROOT}/index.html
    fi
done

# Complete the HTML file
cat >> ${REPO_ROOT}/index.html <<EOF
    </ul>
    
    <h2>Last Updated</h2>
    <p>$(date)</p>
</body>
</html>
EOF

echo "PPA repository updated successfully!"
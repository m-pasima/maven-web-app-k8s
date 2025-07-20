#!/usr/bin/env bash
# install-maven.sh — installs Java 11 & Maven 3.9.x on Amazon Linux (2 or 2023)
set -euo pipefail

### 1) Java 11 installation ###
echo "==> Installing Java 11..."

# Package candidates to try in order:
JAVA_PKGS=( \
  java-11-openjdk-devel \
  java-11-openjdk \
  java-11-amazon-corretto-devel \
  java-11-amazon-corretto-headless \
)

install_cmd() {
  if command -v dnf &>/dev/null; then
    sudo dnf install -y "$@"
  else
    sudo yum install -y "$@"
  fi
}

for pkg in "${JAVA_PKGS[@]}"; do
  echo "   • Trying package: $pkg"
  if install_cmd "$pkg"; then
    echo "   → Installed $pkg"
    break
  else
    echo "   ✗ $pkg not available, trying next"
  fi
done

echo "==> Java version:"
java -version

### 2) Download & install Maven ###
MAVEN_VERSION=3.9.4
INSTALL_DIR=/opt
ARCHIVE="apache-maven-${MAVEN_VERSION}-bin.tar.gz"
URL="https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/${ARCHIVE}"

echo "==> Downloading Maven ${MAVEN_VERSION}..."
curl -fsSL "${URL}" -o /tmp/"${ARCHIVE}"

echo "==> Extracting to ${INSTALL_DIR}..."
sudo tar -xzf /tmp/"${ARCHIVE}" -C "${INSTALL_DIR}"

echo "==> Creating symlink /opt/maven → apache-maven-${MAVEN_VERSION}"
sudo ln -sfn "${INSTALL_DIR}/apache-maven-${MAVEN_VERSION}" "${INSTALL_DIR}/maven"

### 3) Configure environment variables ###
PROFILE=/etc/profile.d/maven.sh
echo "==> Writing environment variables to ${PROFILE}"
sudo tee "${PROFILE}" > /dev/null << 'EOF'
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
export M2_HOME=/opt/maven
export MAVEN_HOME=/opt/maven
export PATH=${M2_HOME}/bin:${PATH}
EOF

sudo chmod +x "${PROFILE}"

# Load for this session
# shellcheck disable=SC1090
source "${PROFILE}"

### 4) Verify Maven ###
echo "==> Maven version:"
mvn -version

echo "==> Installation complete!"

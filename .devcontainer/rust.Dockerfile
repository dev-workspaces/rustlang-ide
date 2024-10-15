FROM --platform=$BUILDPLATFORM ubuntu:23.10

LABEL maintainer="@k33g_org"

ARG TARGETOS
ARG TARGETARCH

ARG RUST_VERSION=${RUST_VERSION}

ARG USER_NAME=${USER_NAME}

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_COLLATE=C
ENV LC_CTYPE=en_US.UTF-8

# Install Tools
RUN <<EOF
apt-get update 
apt-get install -y curl wget git bat exa sudo sshpass build-essential
apt-get -y install hey
ln -s /usr/bin/batcat /usr/bin/bat

apt-get clean autoclean
apt-get autoremove --yes
rm -rf /var/lib/{apt,dpkg,cache,log}/
EOF

# Create a new user
RUN adduser --disabled-password --gecos '' ${USER_NAME}
RUN adduser ${USER_NAME} sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set the working directory
WORKDIR /home/${USER_NAME}

# Install Rust for the new user
RUN <<EOF
su - ${USER_NAME} -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION}"
EOF

# Set Environment Variables for Rust
ENV PATH="/home/${USER_NAME}/.cargo/bin:${PATH}"

# Verify Rust installation and install additional components
#RUN <<EOF
#su - ${USER_NAME} -c "rustc --version && \
#    cargo --version && \
#    rustup component add rustfmt && \
#    rustup component add clippy"
#EOF

RUN <<EOF
su - ${USER_NAME} -c "rustc --version && \
    cargo --version"
EOF

# Set the user as the owner of the working directory
RUN chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}

# Switch to the regular user
USER ${USER_NAME}

# Avoid the message about sudo
RUN touch ~/.sudo_as_admin_successful

# Install OhMyBash
RUN <<EOF
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
EOF
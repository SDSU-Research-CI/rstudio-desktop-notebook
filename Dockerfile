ARG BASE_IMAGE=gitlab-registry.nrp-nautilus.io/nrp/scientific-images/rstudio:cuda-v1.4.1

FROM ${BASE_IMAGE}

ARG UBUNTU_VERSION_CODENAME=jammy
ARG RSTUDIO_VERSION=2024.12.1-563

USER root
WORKDIR /opt

# Install Jupyter Desktop dependencies, zip and vim, RStudio dependencies
RUN apt-get -y update \
 && apt-get -y install \
    dbus-x11 \
    xfce4 \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xorg \
    xubuntu-icon-theme \
    tigervnc-standalone-server \
    tigervnc-xorg-extension \
    zip \
    vim \
    tk \
    tcllib \
    libxkbcommon-x11-0 \
    libnss3 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

RUN wget "https://download1.rstudio.org/electron/${UBUNTU_VERSION_CODENAME}/amd64/rstudio-${RSTUDIO_VERSION}-amd64.deb" \
 && apt install ./"rstudio-${RSTUDIO_VERSION}-amd64.deb" \
 && rm ./"rstudio-${RSTUDIO_VERSION}-amd64.deb"

# Switch back to notebook user
USER $NB_USER
WORKDIR /home/${NB_USER}

# Install Jupyter Desktop proxy
RUN /opt/conda/bin/conda install -y -q -c manics websockify
RUN pip install jupyter-remote-desktop-proxy

ENV LD_LIBRARY_PATH=/opt/conda/lib/R/lib:$LD_LIBRARY_PATH

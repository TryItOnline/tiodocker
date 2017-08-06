FROM fedora:26

LABEL description="TryItOnline Offline Image https://tryitonline.net" maintainer="Andrew Savinykh<andrew@tryitonline.nz>"

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8   

ARG TINI_VER=0.14.0

COPY rootfs /

RUN chmod +x /usr/local/bin/* \
 && dnf update -y \
 && dnf install -y git wget dnf-plugins-core openssh-server glibc-locale-source python gettext vim-common file policycoreutils sudo \
 && pip install --upgrade pip \
 && pip install supervisor \
 && /usr/libexec/openssh/sshd-keygen ed25519 \
 && localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || true \
 && cd /tmp \
 && wget -q https://github.com/krallin/tini/releases/download/v$TINI_VER/tini_$TINI_VER.rpm \
 && dnf install -y tini_$TINI_VER.rpm \
 && git clone https://github.com/TryItOnline/tiosetup.git /opt/tiosetup \
 && cd /opt/tiosetup \
 && git checkout Min \
 && cp /opt/tiodocker/config.docker /opt/tiosetup/private/config \
 && /opt/tiosetup/bootstrap \
 && rm -rf /tmp/* \
 && rm -f /run/nologin

VOLUME /etc/httpd /srv

EXPOSE 80 81

CMD ["tini","--","startup"]

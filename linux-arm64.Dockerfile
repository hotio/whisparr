ARG UPSTREAM_IMAGE
ARG UPSTREAM_TAG_SHA

FROM ${UPSTREAM_IMAGE}:${UPSTREAM_TAG_SHA}
EXPOSE 6969
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="6969/tcp"

RUN apk add --no-cache libintl sqlite-libs icu-libs

ARG VERSION
ARG VERSION_BRANCH
ARG VERSION_URL_ARM64
ARG PACKAGE_VERSION=${VERSION}
RUN --mount=type=secret,id=GIT_AUTH_TOKEN,env=TOKEN \
    mkdir "${APP_DIR}/bin" && \
    extractdir="/tmp/whisparr" && mkdir "${extractdir}" && zipfile="${extractdir}/app.zip" && \
    curl -fsSL -H "Authorization: Bearer ${TOKEN}" -o "${zipfile}" "${VERSION_URL_ARM64}" && \
    unzip -q "${zipfile}" -d "${extractdir}" && \
    tar xzf "${extractdir}/"*.tar.gz -C "${APP_DIR}/bin" --strip-components=1 && \
    rm -rf "${APP_DIR}/bin/Whisparr.Update" "${extractdir}" && \
    echo -e "PackageVersion=${PACKAGE_VERSION}\nPackageAuthor=[hotio](https://github.com/hotio)\nUpdateMethod=Docker\nBranch=${VERSION_BRANCH}" > "${APP_DIR}/package_info" && \
    chmod -R u=rwX,go=rX "${APP_DIR}" && \
    chmod +x "${APP_DIR}/bin/Whisparr"

COPY root/ /
RUN find /etc/s6-overlay/s6-rc.d -name "run*" -execdir chmod +x {} +

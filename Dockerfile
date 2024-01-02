FROM ubuntu:22.04


ENV OTP_VERSION="26.2.1"

run apt-get update
run apt-get install -y curl

# Download Erlang source files
ENV OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz"
ENV OTP_DOWNLOAD_SHA256="d99eab3af908b41dd4d7df38f0b02a447579326dd6604f641bbe9f2789b5656b"

RUN set -xe \
	&& curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" \
	&& echo "$OTP_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c -

# extract files
RUN set -xe \
  && ERL_TOP="/usr/src/otp_src_${OTP_VERSION%%@*}" \
	&& mkdir -vp $ERL_TOP \
	&& tar -xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1 \
	&& rm otp-src.tar.gz

run apt-get install -y build-essential
run apt-get install -y libncurses5-dev
run apt-get install -y libssl-dev
run apt-get install -y libwxgtk3.0-gtk3-dev
# run apt-get install -y xsltproc
# run apt-get install -y libxml2-utils
# run apt-get install -y fop

# Build sources and documentation
RUN set -xe \
  && ERL_TOP="/usr/src/otp_src_${OTP_VERSION%%@*}" \
	&& ( cd $ERL_TOP \
			&& ./otp_build autoconf \
			&& ./configure \
			&& make -j$(nproc) \
			&& make -j$(nproc) docs DOC_TARGETS=chunks \
			&& make install \
      && make install-docs DOC_TARGETS=chunks ) \
	&& find /usr/local -name examples | xargs rm -rf \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf $ERL_TOP /var/lib/apt/lists/*

#CMD ["erl"]

# elixir expects utf8.
ENV ELIXIR_VERSION="v1.16.0" \
	LANG=C.UTF-8

RUN set -xe \
	&& ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
	&& ELIXIR_DOWNLOAD_SHA256="d7fe641e3c85c9774232618d22c880c86c2f31e3508c344ce75d134cd40aea18" \
	&& curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
	&& echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/local/src/elixir \
	&& tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
	&& rm elixir-src.tar.gz \
	&& cd /usr/local/src/elixir \
	&& make install clean \
	&& find /usr/local/src/elixir/ -type f -not -regex "/usr/local/src/elixir/lib/[^\/]*/lib.*" -exec rm -rf {} + \
	&& find /usr/local/src/elixir/ -type d -depth -empty -delete

CMD ["iex"]

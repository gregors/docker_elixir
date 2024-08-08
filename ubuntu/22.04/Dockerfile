FROM ubuntu:22.04

ENV OTP_VERSION="27.0.1"

run apt-get update
run apt-get install -y curl

# Download Erlang source files
ENV OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz"
ENV OTP_DOWNLOAD_SHA256="47d96bb7044cf44bca886213fa828ef82457a911b7622c453d9b3c615b6f68ab"

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
run apt-get install -y unixodbc-dev
run apt-get install -y libncurses5-dev
run apt-get install -y libssl-dev
run apt-get install -y libwxgtk3.0-gtk3-dev

# Build sources and documentation
RUN set -xe \
  && ERL_TOP="/usr/src/otp_src_${OTP_VERSION%%@*}" \
	&& ( cd $ERL_TOP \
			&& ./configure \
			&& make -j$(nproc) \
			&& make -j$(nproc) docs DOC_TARGETS=chunks \
			&& make install \
      && make install-docs DOC_TARGETS=chunks ) \
	&& find /usr/local -name examples | xargs rm -rf \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf $ERL_TOP /var/lib/apt/lists/*

# elixir expects utf8.
ENV LANG=C.UTF-8
ENV ELIXIR_VERSION="v1.17.2"

ENV ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz"
ENV ELIXIR_DOWNLOAD_SHA256="7bb8e6414b77c1707f39f620a2ad54f68d64846d663ec78069536854247fb1ab"

RUN set -xe \
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

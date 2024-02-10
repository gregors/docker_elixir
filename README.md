# Building Elixir on Ubuntu

## Some Docs & implemenations I looked at
* https://github.com/erlang/otp/blob/master/HOWTO/INSTALL.md
* https://github.com/erlang/docker-erlang-otp/blob/master/26/Dockerfile
* https://github.com/erlef/docker-elixir/blob/master/1.16/otp-25/Dockerfile

## to build
docker buildx build --progress=plain -t elixir .

## to run
docker run -it --rm elixir

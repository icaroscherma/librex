FROM docker:20.10
WORKDIR "/home/librex"

# Docker metadata contains information about the maintainer, such as the name, repository, and support email
# Please add any necessary information or correct any incorrect information
# See more: https://docs.docker.com/config/labels-custom-metadata/
LABEL name="LibreX" \
      description="Framework and javascript free privacy respecting meta search engine" \
      version="1.0" \
      vendor="Hnhx Femboy<femboy.hu>" \
      url="https://github.com/hnhx/librex" \
      usage="https://github.com/hnhx/librex/wiki" \
      authors="https://github.com/hnhx/librex/contributors"

# Include arguments as temporary environment variables to be handled by Docker during the image build process
# Change or add new arguments to customize the image generated by 'docker build' command
ARG DOCKER_SCRIPTS=".docker"

# Customize the environment during both execution and build time by modifying the environment variables added to the container's shell
# When building your image, make sure to set the 'TZ' environment variable to your desired time zone location, for example 'America/Sao_Paulo'
# See more: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List
ENV TZ="America/New_York"
ENV PATH="/docker/bin:$PATH"
ENV OPENSEARCH_HOST="http://localhost:80"

# Include docker scripts, docker images, and the 'GNU License' in the Librex container
ADD "${DOCKER_SCRIPTS}/*" "/docker/scripts/"
ADD "." "/docker/"

# Set permissions for script files as executable scripts inside 'docker/scripts' directory
RUN   chmod u+x "/docker/scripts/entrypoint.sh" &&\
      chmod u+x "/docker/scripts/build.sh"

# Add 'zip' package to generate a temporary compressed 'librex.zip' for best recursive copy between Docker images
# Remove unnecessary folders and create a temporary folder that will contain the zip file created earlier
# Compress Librex files, excluding the '.docker' folder containing scripts and the Dockerfile, using the previously downloaded zip package
# Delete all files in the root directory, except for the '.docker' and 'tmp' folders, which are created exclusively to be handled by Docker
RUN   apk update; apk add zip --no-cache &&\
      rm -rf .git; mkdir -p "tmp/zip" &&\
      zip -r "tmp/zip/librex.zip" . -x "./scripts/**\*" "./Dockerfile\*" &&\
      find -maxdepth 1 ! -name "scripts/" ! -name "tmp/" ! -name "./" -exec rm -rv {} \; &&\
      apk del -r zip; apk cache clean;

# Configures the container to be run as an executable.
ENTRYPOINT ["/bin/sh", "-c", "/docker/scripts/entrypoint.sh"]

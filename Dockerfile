
#=========================================================
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#image-relationships
#  docker run -p 8888:8888/tcp jupyter/scipy-notebook start-notebook.sh
#=========================================================
FROM jupyter/scipy-notebook



USER root

### Doc
# Build as:
# docker build -t username/appname .
# Run as:
# docker run -it --rm -p 8989:8080 username/appname
#####

#=========================================================
# next is due to a bug
#=========================================================

ENV export DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y git

## https://dev.to/jake/using-libcurl3-and-libcurl4-on-ubuntu-1804-bionic-184g
# RUN apt-get update -qq && apt-get -y --no-install-recommends install libcurl3 \
#   && cp /usr/lib/x86_64-linux-gnu/libcurl.so.3 /usr/lib/ \

# RUN apt-get update && apt-get install -y --no-install-recommends \
#   curl libcurl4-openssl-dev libgit2 \
# RUN apt-get update -qq && apt-get -y --no-install-recommends install \
#   nodejs \
#   nodejs-dev \
#   libssl1.0-dev \
#   node-gyp \
#   npm \
#   libssl-dev

# RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update

#=========================================================
# From https://hub.docker.com/r/rocker/r-ubuntu/dockerfile
#=========================================================

# LABEL org.label-schema.license="GPL-2.0" \
#       org.label-schema.vcs-url="https://github.com/rocker-org/r-apt" \
#       org.label-schema.vendor="Rocker Project" \
#       maintainer="Dirk Eddelbuettel <edd@debian.org>"

## Set a default user. Available via runtime flag `--user docker` 
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly). 
RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		software-properties-common \
                ed \
		less \
		locales \
		vim-tiny \
		wget \
		ca-certificates \
        && add-apt-repository --enable-source --yes "ppa:marutter/rrutter3.5" \
	&& add-apt-repository --enable-source --yes "ppa:marutter/c2d4u3.5" 

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## This was not needed before but we need it now
ENV DEBIAN_FRONTEND noninteractive

# Now install R and littler, and create a link for littler in /usr/local/bin
# Default CRAN repo is now set by R itself, and littler knows about it too
# r-cran-docopt is not currently in c2d4u so we install from source
RUN apt-get update \
        && apt-get install -y --no-install-recommends \
                 littler \
 		 r-base \
 		 r-base-dev \
 		 r-recommended \
  	&& ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
 	&& ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
 	&& ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
 	&& ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
 	&& install.r docopt \
 	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
 	&& rm -rf /var/lib/apt/lists/*

CMD ["bash"]

#=========================================================
# From https://github.com/lanl/dfnWorks/blob/master/Dockerfile
#=========================================================
RUN ["apt-get","update","-y"]

# 2. Add pre-required packages
ENV DEBIAN_FRONTEND=noninteractive
RUN ["apt-get","install","-y","build-essential","gfortran","cmake","git","python","python-pip"]
RUN ["apt-get","install","-y","wget","libz-dev","m4","bison","python3","python3-pip","python3-tk","vim","curl"]
RUN ["apt-get","install","-y","pkg-config","openssh-client","openssh-server","valgrind"]

# RUN ["pip3","install","setuptools","numpy","h5py","matplotlib","scipy","networkx"] # user error

#=========================================================
# From https://hub.docker.com/r/rocker/tidyverse/dockerfile
#=========================================================
RUN apt-get install -y curl && apt-get update
RUN apt-get install -y libcurl4-openssl-dev # for 'curl' R package
RUN apt-get install -y libssl-dev # for 'httr' R package
# RUN apt-get install -y bliss # for 'igraph' package
RUN apt-get install -y libopenblas-base
RUN apt-get -y install libxt-dev r-cran-xml
RUN apt-get -y install libmysqlclient-dev libmysqlclient20 default-libmysqlclient-dev
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install libboost-all-dev mysql-server
RUN apt-get -y update && apt-get -y upgrade

RUN Rscript -e 'install.packages(c("curl", "httr"), repos="https://cran.rstudio.com")' \
  # && Rscript -e 'install.packages("httr", repos="https://cran.rstudio.com")' \
  && Rscript -e 'install.packages("igraph")' \
  && Rscript -e 'install.packages(c("BH", "highlight"))'

RUN apt-get update -qq && apt-get -yq --no-install-recommends install \
  libxml2-dev \
  libcairo2-dev \
  libsqlite3-dev \
  libmariadbd-dev \
  libmariadb-client-lgpl-dev \
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev \
  libsasl2-dev

RUN Rscript -e 'install.packages(c("tidyverse", "dplyr", "devtools", "formatR", "remotes", "selectr", "caTools", "BiocManager"))'

RUN apt-get -y install default-libmysqlclient-dev libmysqlclient-dev mysql-server

#=========================================================
# https://hub.docker.com/r/rocker/geospatial/dockerfile
#=========================================================

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    lbzip2 \
    default-libmysqlclient-dev \
    libfftw3-dev \
    libgdal-dev \
    libgeos-dev \
    libgsl0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libhdf4-alt-dev \
    libhdf5-dev \
    libjq-dev \
    liblwgeom-dev \
    libpq-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    libsqlite3-dev \
    libudunits2-dev \
    netcdf-bin \
    postgis \
    protobuf-compiler \
    sqlite3 \
    tk-dev \
    unixodbc-dev
  
RUN Rscript -e 'install.packages(c("RColorBrewer", "RandomFields", "RNetCDF", "classInt", "deldir"))' && \
  Rscript -e 'install.packages(c("gstat", "hdf5r", "lidR", "mapdata", "maptools", "mapview"))' && \
  Rscript -e 'install.packages(c("ncdf4", "proj4", "raster", "rgdal", "rgeos", "rlas"))' && \
  Rscript -e 'install.packages(c("sf", "sp", "spacetime", "spatstat", "spatialreg", "spdep"))' && \
  Rscript -e 'install.packages(c("spdep", "geoR", "geosphere"))' && \
  Rscript -e 'BiocManager::install("rhdf5")'

#=========================================================
# Packages I use
#=========================================================

# RUN apt-get update -qq && apt-get -y --no-install-recommends install \ 
#   libc6 \
#   libc6-dev \
#   bison \
#   flex \
#   graphviz \
#   libunwind-dev && \
#   apt-get update -y

# RUN Rscript -e 'install.packages(c("RcppEigen", "ggplot2", "Cairo", "evaluate"))' && \
#   Rscript -e 'install.packages(c("highr", "markdown", "yaml", "knitr", "rmarkdown", "htmltools"))' && \
#   Rscript -e 'install.packages(c("roxygen2", "testthat", "snow", "Rmpi", "doSNOW", "foreach"))' && \
#   Rscript -e 'install.packages(c("DependenciesGraph", "Rdpack", "RSQLite", "feather", "httr", "jsonlite"))' && \
#   Rscript -e 'install.packages(c("lubridate", "readxl", "xts", "stringr", "compare", "splitstackshape"))' && \
#   Rscript -e 'install.packages(c("reshape2", "fuzzyjoin", "scales", "automap", "lmomRFA", "lmomco"))' && \
#   Rscript -e 'install.packages(c("gdata", "maps", "ggmap", "leaflet", "leaflet.extras", "geojsonio"))' && \
#   Rscript -e 'install.packages(c("copula", "copBasic", "TwoCop", "RFOC", "circular", "movMF"))' && \
#   Rscript -e 'install.packages(c("VecStatGraphs2D", "distr", "fitdistrplus", "actuar", "polynom", "splines"))' && \
#   Rscript -e 'install.packages(c("squash", "mlbench", "gower", "cluster", "dtw", "randomForest"))' && \
#   Rscript -e 'install.packages(c("corrplot", "lpSolve", "digest", "glue", "rvest", "ptinpoly"))' && \
#   Rscript -e 'install.packages(c("misc3d", "geometry"))'

# RUN Rscript -e 'install.packages("IRkernel")' && \
#   Rscript -e "IRkernel::installspec(user = FALSE)"

# RUN Rscript -e 'devtools::install_github("mathphysmx/cleanTable")' && \
#   Rscript -e 'devtools::install_github("mathphysmx/gmshR")' && \
#   Rscript -e 'devtools::install_github("mathphysmx/percolation")' && \
#   Rscript -e 'devtools::install_github("mathphysmx/empiricalDistribution")' && \
#   Rscript -e 'devtools::install_github("mathphysmx/inverseFunction")' && \
#   Rscript -e 'devtools::install_github("mathphysmx/bernstein", build_vignettes = TRUE)'

CMD ["bash"]

#=========================================================
# https://hub.docker.com/r/rocker/ml/dockerfile
#=========================================================



FROM pditommaso/dkrbase:1.2
MAINTAINER Maria Chatzou <mxatzou@gmail.com>


RUN apt-get update -y --fix-missing && apt-get install -y \
    git \
    cmake \
    libargtable2-dev \
    python-numpy \
    python-qt4 \
    python-lxml \
    python-six

RUN pip install --upgrade ete3

RUN ete3 upgrade-external-tools


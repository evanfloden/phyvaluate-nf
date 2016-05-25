FROM pditommaso/dkrbase:1.2
MAINTAINER Maria Chatzou <mxatzou@gmail.com>


RUN apt-get update -y --fix-missing && apt-get install -y \
    git \
    cmake \
    libargtable2-dev

RUN apt-get install -y bzip2
RUN apt-get install -y python-numpy python-qt4 python-lxml python-six


RUN wget http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh -O Miniconda-latest-Linux-x86_64.sh
RUN bash Miniconda-latest-Linux-x86_64.sh -b -p ~/anaconda_ete/

RUN cp ~/anaconda_ete/bin/conda /usr/local/bin/
RUN conda install -c etetoolkit ete3 ete3_external_apps

RUN cp ~/anaconda_ete/bin/ete3 /usr/local/bin/

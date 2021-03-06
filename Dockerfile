FROM kbase/sdkbase2:python
MAINTAINER KBase Developer
# -----------------------------------------
# In this section, you can install any system dependencies required
# to run your App.  For instance, you could place an apt-get update or
# install line here, a git checkout to download code, or run any other
# installation scripts.

RUN echo "start building docker image"

RUN apt-get update \
    && apt-get -y install python3-dev \
    && apt-get -y install wget \
    && apt-get -y install gcc \
    && apt-get -y install cmake \
    && apt-get -y install build-essential \
    && apt-get -y install zlib1g-dev \
    && apt-get -y install bowtie \
    && apt-get -y install bowtie2 \
    && apt-get -y install ncbi-blast+ \
    && apt-get -y install samtools

RUN pip install --upgrade pip \
    && pip3 install psutil \
    && python --version

ENV UNICYCLER_VERSION='0.4.8'
ENV SPADES_VERSION='3.13.2'
ENV RACON_VERSION='1.4.13'
ENV PILON_VERSION='1.23'

# use conda version of SPAdes instead of authors' version,
# because spades-hammer from the latter crashes on some linux distros,
# including Debian and Arch
RUN cd /opt \
    && wget https://anaconda.org/bioconda/spades/${SPADES_VERSION}/download/linux-64/spades-${SPADES_VERSION}-h2d02072_0.tar.bz2 \
    && mkdir spades-${SPADES_VERSION} \
    && cd spades-${SPADES_VERSION} \
    && tar -xvjf ../spades-${SPADES_VERSION}-h2d02072_0.tar.bz2 \
    && rm ../spades-${SPADES_VERSION}-h2d02072_0.tar.bz2

RUN cd /opt \
    && wget https://github.com/lbcb-sci/racon/releases/download/${RACON_VERSION}/racon-v${RACON_VERSION}.tar.gz \
    && tar -xvzf racon-v${RACON_VERSION}.tar.gz \
    && rm racon-v${RACON_VERSION}.tar.gz \
    && cd racon-v${RACON_VERSION} \
    && cmake -DCMAKE_BUILD_TYPE=Release \
    && make

RUN cd /opt/ \
    && mkdir pilon \
    && cd pilon \
    && wget https://github.com/broadinstitute/pilon/releases/download/v${PILON_VERSION}/pilon-${PILON_VERSION}.jar \
    && echo '#!/bin/bash' > pilon \
    && echo "java -Xmx64G -jar /opt/pilon/pilon-${PILON_VERSION}.jar \$@" >> pilon \
    && chmod +x pilon

ENV PATH $PATH:/opt/spades-${SPADES_VERSION}/bin:/opt/racon-v${RACON_VERSION}/bin:/opt/pilon/

RUN cd /opt \
    && wget https://github.com/rrwick/Unicycler/archive/v${UNICYCLER_VERSION}.tar.gz \
    && tar -xvzf v${UNICYCLER_VERSION}.tar.gz \
    && rm v${UNICYCLER_VERSION}.tar.gz \
    && cd Unicycler-${UNICYCLER_VERSION} \
    && python3 setup.py install

# -----------------------------------------

COPY ./ /kb/module
RUN mkdir -p /kb/module/work
RUN chmod -R a+rw /kb/module

WORKDIR /kb/module

RUN make

ENTRYPOINT [ "./scripts/entrypoint.sh" ]

CMD [ ]

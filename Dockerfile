FROM imagedata/jupyter-docker:0.9.2
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

# R-kernel and R-OMERO prerequisites
ADD environment-r-omero.yml .setup/
RUN conda env update -n r-omero -q -f .setup/environment-r-omero.yml && \
    /opt/conda/envs/r-omero/bin/Rscript -e "IRkernel::installspec(displayname='OMERO R')"

USER root
RUN mkdir /opt/romero /opt/omero && \
    fix-permissions /opt/romero /opt/omero
# R requires these two packages at runtime
RUN apt-get install -y -q \
    libxrender1 \
    libsm6
USER $NB_UID

# install rOMERO
ENV _JAVA_OPTIONS="-Xss2560k -Xmx2g"
ENV OMERO_LIBS_DOWNLOAD=TRUE
ARG ROMERO_VERSION=v0.4.7
RUN cd /opt/romero && \
    curl -sf https://raw.githubusercontent.com/ome/rOMERO-gateway/$ROMERO_VERSION/install.R --output install.R && \
    bash -c "source activate r-omero && Rscript install.R --version=$ROMERO_VERSION --quiet"

# Clone the source git repo into notebooks (keep this at the end of the file)
COPY --chown=1000:100 . notebooks

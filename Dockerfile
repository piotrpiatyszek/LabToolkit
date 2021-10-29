FROM ubuntu:focal

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    PATH=/opt/conda/bin:/usr/lib/rstudio-server/bin:$PATH \
    DEBIAN_FRONTEND=noninteractive \
    SHELL=/bin/bash \
    R_VERSION=4.1.1

EXPOSE 8801
EXPOSE 8802
EXPOSE 8803

RUN mkdir /workspace
VOLUME /workspace

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 git mercurial subversion && \
    apt-get install -y --no-install-recommends bash-completion devscripts file fonts-texgyre g++ gfortran gsfonts libbz2-* \
    libcurl4 libicu* libpcre2* libjpeg-turbo* libpangocairo-* libpng16* libtiff* liblzma* locales make unzip zip zlib1g libxml2-dev && \
    apt-get clean

RUN git clone https://github.com/rocker-org/rocker-versioned2 /tmp/rocker && \
    cp -R /tmp/rocker/scripts /rocker_scripts && \
    rm -rf /tmp/rocker
ENV DEFAULT_USER=root
RUN ln -s /root /home/root
RUN /rocker_scripts/install_R.sh
RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_tidyverse.sh

RUN sed -i 's/8787/8801/' /rocker_scripts/rsession.sh
RUN echo 'www-port=8801' >> /etc/rstudio/disable_auth_rserver.conf
RUN echo 'auth-minimum-user-id=0' >> /etc/rstudio/disable_auth_rserver.conf
RUN echo 'session-default-working-dir=/workspace' >> /etc/rstudio/rsession.conf
RUN echo 'session-default-new-project-dir=/workspace' >> /etc/rstudio/rsession.conf
RUN R -e "devtools::install_github('IRkernel/IRkernel')"

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN sed -i 's/"display_name": "Python 3"/"display_name": "Python 3.8"/' /opt/conda/share/jupyter/kernels/python3/kernel.json

RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && \
                  conda create --name python3.6 python=3.6 && \
                  conda activate python3.6 && \
                  conda install ipykernel scipy numpy pandas scikit-learn beautifulsoup4 black Cython flake8 ipywidgets matplotlib Pillow pep8 pylint pyodbc seaborn SQLAlchemy tqdm Werkzeug urllib3 && \
                  python -m ipykernel install --user --name python3.6 --display-name='Python 3.6'"

RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && \
                  conda create --name python3.7 python=3.7 && \
                  conda activate python3.7 && \
                  conda install ipykernel scipy numpy pandas scikit-learn beautifulsoup4 black Cython flake8 ipywidgets matplotlib Pillow pep8 pylint pyodbc seaborn SQLAlchemy tqdm Werkzeug urllib3 && \
                  python -m ipykernel install --user --name python3.7 --display-name='Python 3.7'"

RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && \
                  conda create --name python3.9 python=3.9 && \
                  conda activate python3.9 && \
                  conda install ipykernel scipy numpy pandas scikit-learn beautifulsoup4 black Cython flake8 ipywidgets matplotlib Pillow pep8 pylint pyodbc seaborn SQLAlchemy tqdm Werkzeug urllib3 && \
                  python -m ipykernel install --user --name python3.9 --display-name='Python 3.9'"

RUN find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

RUN R -e "IRkernel::installspec(user = FALSE)"

RUN mkdir /etc/services.d/jupyterlab
COPY start_jupyterlab.sh /etc/services.d/jupyterlab/run

RUN curl -fsSL https://code-server.dev/install.sh | sh -s --
RUN mkdir /etc/services.d/vsc
COPY start_vsc.sh /etc/services.d/vsc/run
RUN SERVICE_URL="https://open-vsx.org/vscode/gallery" ITEM_URL="https://open-vsx.org/vscode/item" code-server --install-extension ms-python.python
RUN SERVICE_URL="https://open-vsx.org/vscode/gallery" ITEM_URL="https://open-vsx.org/vscode/item" code-server --install-extension ms-toolsai.jupyter

COPY inject_ssh_key.sh /etc/cont-init.d/inject_ssh_key.sh

ENV DISABLE_AUTH=true \
    ROOT=true

CMD ["/init"]

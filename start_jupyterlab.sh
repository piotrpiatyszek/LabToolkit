#!/usr/bin/with-contenv bash
/opt/conda/bin/jupyter-lab --notebook-dir=/workspace --ip='*' --NotebookApp.token='' --NotebookApp.base_url=`echo $JUPYTER_PATH` --port=8802 --no-browser --allow-root --NotebookApp.allow_origin=`echo $DOMAIN` --NotebookApp.disable_check_xsrf=True

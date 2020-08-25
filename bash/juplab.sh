#This function requires python venv and jupyterlab to be installed.
#add the following function to your bashrc file:
function juplab() {
  source <local/path/to/venvs>$2/bin/activate;jupyter lab --no-browser --port=8666 --NotebookApp.ip="<ip-address>$1"
}

#Inside of your terminal:
export -f juplab

#Example Usage:
juplab 1 jordivenv

#Becomes:source $USER/virtual_environments/jordivenv/bin/activate;jupyter lab --no-browser --port=8666 --NotebookApp.ip="0.0.0.1"

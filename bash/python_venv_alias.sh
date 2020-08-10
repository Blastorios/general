#!/bin/bash

for d in <path to collected venvs>/*; do
  alias ae_$(basename $d)="source $d/bin/activate"
done
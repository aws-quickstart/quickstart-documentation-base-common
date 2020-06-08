#!/bin/bash
# Wrapper to generate parameter tables within asciidoc workflow.
sudo apt-get install pandoc -y
pip3 install -r docs/boilerplate/.utils/requirements.txt;
echo "Gen tables"
python docs/boilerplate/.utils/generate_parameter_tables.py

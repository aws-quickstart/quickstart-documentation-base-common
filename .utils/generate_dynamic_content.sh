#!/bin/bash
# Wrapper to generate parameter tables within asciidoc workflow.
sudo apt-get install pandoc -y
pip3 install -r docs/common/.utils/requirements.txt; 
ls -l docs/
ls -l docs/common/
echo "Gen tables"
python docs/common/.utils/generate_parameter_tables.py

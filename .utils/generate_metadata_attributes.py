#!/usr/bin/env python
import io
import cfnlint
from pathlib import Path


def get_cfn(filename):
    _decoded = cfnlint.decode.decode(filename, False)[0]
    return _decoded

def fetch_metadata():
    metadata_attributes = []
    for yaml_cfn_file in Path('./templates').glob('*.template*'):
        template = get_cfn(Path(yaml_cfn_file))
        if not template:
            raise Exception(f"cfn-lint failed to load {yaml_cfn_file} without errors. Failure")
        _resources = template['Resources']
        for _resource in _resources:
            _type = _resource['Type'].lower()
            metadata_attributes.append(_type.split('::')[1])
            metadata_attributes.append(_type.replace('::','_'))
    with open('docs/generated/services/metadata.adoc', 'w') as f:
        for attr in metadata_attributes:
            f.write(f":template_{attr}:")

if __name__ == '__main__':
    fetch_metadata()

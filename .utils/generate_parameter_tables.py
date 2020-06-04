#!/usr/bin/env python
import io
import cfnlint
import datetime
from pathlib import Path


def get_cfn(filename):
    _decoded = cfnlint.decode.decode(filename, False)[0]
    return _decoded

def _generate_table_name_and_header(label_name):
    data = []
    data.append(f"\n.{label_name}")
    data.append('[width="100%",cols="16%,11%,73%",options="header",]')
    data.append("|===")
    data.append("|Parameter label (name) |Default Value|Description")
    return "\n".join(data)

def _generate_per_label_table_entry(label, param, default, description):
    data = []
    if not label:
        label = "**NO_LABEL**"
    data.append(f"|{label}")
    data.append(f"(`{param}`)|`{default}`|{description}")
    return '\n'.join(data)

def just_pass():
    template_entrypoints = {}
    for yaml_cfn_file in Path('./templates').glob('*.yaml'):
        print(f"Working on {yaml_cfn_file}")
        template = get_cfn(Path(yaml_cfn_file))
        if not template:
            raise Exception(f"cfn-lint failed to load {yaml_cfn_file} without errors. Failure")
        entrypoint = template.get('Metadata', {}).get('Documentation', {}).get('EntrypointName')
        if not entrypoint:
            print(f"- No documentation entrypoint found. Continuing.")
            continue
        _pf = Path(yaml_cfn_file).stem + ".adoc"
        p_file = f"docs/generated/parameters/{_pf}"
        template_entrypoints[p_file.split('/')[-1]] = entrypoint

        label_mappings = {}
        reverse_label_mappings = {}
        parameter_mappings = {}
        parameter_labels = {}
        no_groups = {}

        def determine_optional_value(param):
            optional = template['Metadata'].get('Documentation', {}).get('OptionalParameters')
            if optional and (param in optional):
                return '__Optional__'
            return '**__Requires Input__**'

        for label in template['Metadata']['AWS::CloudFormation::Interface']['ParameterGroups']:
            label_name = label['Label']['default']
            label_params = label['Parameters']
            label_mappings[label_name] = label_params
            for ln in label_params:
                reverse_label_mappings[ln] = label_name

        for label_name, label_data in template['Metadata']['AWS::CloudFormation::Interface']['ParameterLabels'].items():
            parameter_labels[label_name] = label_data.get('default')

        for label_name, label_data in template['Parameters'].items():
            parameter_mappings[label_name] = label_data
            if not reverse_label_mappings.get(label_name):
                no_groups[label_name] = label_data

        adoc_data = ""
        for label_name, label_params in label_mappings.items():
            header = _generate_table_name_and_header(label_name)
            adoc_data += header

            for lparam in label_params:
                param_data = _generate_per_label_table_entry(
                        parameter_labels.get(lparam, ''),
                        lparam,
                        parameter_mappings[lparam].get('Default', determine_optional_value(lparam)),
                        parameter_mappings[lparam].get('Description', 'NO_DESCRIPTION')
                )
                adoc_data += param_data
            adoc_data += "\n|==="

        print(f"- Generating: {p_file}")
        with open (p_file, 'w') as p:
            p.write(adoc_data)

    if not template_entrypoints:
        raise Exception("No documentation entrypoints were found. Unable to build documentation. Exiting.")
    with open('docs/generated/parameters/index.adoc', 'w') as f:
        for template_file, cosmetic_name in template_entrypoints.items():
            f.write(f"\n=== {cosmetic_name}\n")
            f.write(f"include::{template_file}[]\n")

if __name__ == '__main__':
    print("---")
    print("> Milton, don't be greedy. Let's pass it along and make sure everyone gets a piece.")
    print("> Can I keep a piece, because last time I was told that...")
    print("> Just pass.")
    print("---")
    just_pass()
    print("---")

#!/bin/bash -e
# # Work in progress.
# exit 1

#Adds Options for the following: ((Help/Second Language/CDK/Terraform options) (-h | -l | -c | -t))
while getopts hlct  option
do
    case "${option}" in
      h )
          echo "Usage:"
          echo "Run './create_repo_structure.sh' with no options for English language only."
          echo "Run './create_repo_structure.sh -l' to add files for second language."
          echo "Run './create_repo_structure.sh -c' for CDK setup."
          echo "Run './create_repo_structure.sh -t' for Terraform setup."
          echo "You can also add the '-l' to the '-c' or '-t' flags to get second language support."
          echo "Ex. './create_repo_structure.sh -c -l'"
          echo " "
          echo "(-h)       Show usage and brief help"
          echo "(-l)       Use to add files for second language for translation"
          echo "(-c)       Use to configure for a CDK Quick Start"
          echo "(-t)       Use to configure for a Terraform Quick Start"
          exit 0
          ;;
      l )
          CREATESECONDLANG="create_second_lang";;
      c )
          CDKSETUP="setup_cdk";;
      t )
          TERRAFORMSETUP="setup_cdk";;
      * )
          echo "this is in an invalid flag. Please see "-h" for help on valid flags"
          exit 0
          ;;
    esac
done

#Creates Standard English directory structure to the repo.
function create_repo() {
BOILERPLATE_DIR="docs/boilerplate"
GENERATED_DIR="docs/generated"
SPECIFIC_DIR="docs/partner_editable"
# Creating directories.
mkdir -p ${GENERATED_DIR}/parameters
mkdir -p ${GENERATED_DIR}/regions
mkdir -p ${GENERATED_DIR}/services
mkdir -p ${SPECIFIC_DIR}
mkdir -p docs/images
mkdir -p .github/workflows

# Copying content.
rsync -avP ${BOILERPLATE_DIR}/.images/ docs/images/
rsync -avP ${BOILERPLATE_DIR}/.specific/ ${SPECIFIC_DIR} --exclude .cdk --exclude .terraform

# creating placeholders.
echo "// placeholder" > ${GENERATED_DIR}/parameters/index.adoc
echo "// placeholder" > ${GENERATED_DIR}/regions/index.adoc
echo "// placeholder" > ${GENERATED_DIR}/services/index.adoc
echo "// placeholder" > ${GENERATED_DIR}/services/metadata.adoc
}

#Creates standard English and second language directory structures to the repo.
function create_second_lang() {
if [ ! -d "docs/partner_editable" ];
 then
   create_repo
   create_second_lang_sub
 else
   BOILERPLATE_DIR="docs/boilerplate"
   GENERATED_DIR="docs/generated"
   SPECIFIC_DIR="docs/partner_editable"
   create_second_lang_sub
 fi
}

function create_second_lang_sub() {
read -p "Please enter enter 2 character language code: " LANG_CODE
LANG_DIR="docs/languages"
SPECIFIC_LANG_DIR="docs/languages/docs-${LANG_CODE}"
TRANSLATE_ONLY="docs/languages/docs-${LANG_CODE}/translate-only"
LANG_FOLDER="docs-${LANG_CODE}"
mkdir -p ${LANG_DIR}
mkdir -p ${SPECIFIC_LANG_DIR}
mkdir -p ${TRANSLATE_ONLY}
rsync -avP ${SPECIFIC_DIR}/ ${SPECIFIC_LANG_DIR}/partner_editable --exclude .cdk --exclude .terraform
rsync -avP ${BOILERPLATE_DIR}/*.adoc ${TRANSLATE_ONLY} --exclude *.lang.adoc --exclude index.adoc --exclude _layout_cfn.adoc --exclude planning_deployment.adoc
rsync -avP ${BOILERPLATE_DIR}/_layout_cfn.lang.adoc ${SPECIFIC_LANG_DIR}/_layout_cfn.adoc
rsync -avP ${BOILERPLATE_DIR}/index.lang.adoc ${SPECIFIC_LANG_DIR}/index.adoc
rsync -avP ${BOILERPLATE_DIR}/planning_deployment.lang.adoc ${TRANSLATE_ONLY}/planning_deployment.adoc
rsync -avP ${BOILERPLATE_DIR}/index-docinfo-footer.html ${TRANSLATE_ONLY}
rsync -avP ${BOILERPLATE_DIR}/LICENSE ${TRANSLATE_ONLY}
sed -i "" "s/docs-lang-code/${LANG_FOLDER}/g" ${SPECIFIC_LANG_DIR}/index.adoc
}


#Creates CDK specific structures to the repo.
function setup_cdk() {
CDK_DIR=".cdk"
create_repo
rm -f ${BOILERPLATE_DIR}/cost.adoc
rm -f ${SPECIFIC_DIR}/partner_editable/deployment_options.adoc
rsync -avP ${BOILERPLATE_DIR}/.specific/${CDK_DIR}/cost.adoc ${BOILERPLATE_DIR}
rsync -avP ${BOILERPLATE_DIR}/.specific/${CDK_DIR}/deployment_options.adoc ${SPECIFIC_DIR}
rsync -avP ${BOILERPLATE_DIR}/.specific/${CDK_DIR}/deploy_steps.adoc ${SPECIFIC_DIR}
sed -i "" "s/:parameters_as_appendix:/\/\/ :parameters_as_appendix:/g" ${SPECIFIC_DIR}/_settings.adoc
sed -i "" "s/\/\/ :cdk_qs:/:cdk_qs:/g" ${SPECIFIC_DIR}/_settings.adoc
sed -i "" "s/\/\/ :no_parameters:/:no_parameters:/g" ${SPECIFIC_DIR}/_settings.adoc
sed -i "" "s/\/\/ :git_repo_url:/:git_repo_url:/g" ${SPECIFIC_DIR}/_settings.adoc
}

#Creates Terraform specific structures to the repo.
function setup_terraform() {
TERRAFORM_DIR=".terraform"
create_repo
rm -f ${BOILERPLATE_DIR}/cost.adoc
rm -f ${SPECIFIC_DIR}/partner_editable/deployment_options.adoc
rsync -avP ${BOILERPLATE_DIR}/.specific/${TERRAFORM_DIR}/cost.adoc ${BOILERPLATE_DIR}
rsync -avP ${BOILERPLATE_DIR}/.specific/${TERRAFORM_DIR}/deployment_options.adoc ${SPECIFIC_DIR}
rsync -avP ${BOILERPLATE_DIR}/.specific/${TERRAFORM_DIR}/deploy_steps.adoc ${SPECIFIC_DIR}
sed -i "" "s/:parameters_as_appendix:/\/\/ :parameters_as_appendix:/g" ${SPECIFIC_DIR}/_settings.adoc
sed -i "" "s/\/\/ :terraform_qs:/:terraform_qs:/g" ${SPECIFIC_DIR}/_settings.adoc
sed -i "" "s/\/\/ :no_parameters:/:no_parameters:/g" ${SPECIFIC_DIR}/_settings.adoc
sed -i "" "s/\/\/ :git_repo_url:/:git_repo_url:/g" ${SPECIFIC_DIR}/_settings.adoc
}


while true
do
#clear
if [ $OPTIND -eq 1 ]; then create_repo; fi
shift $((OPTIND-1))
#printf "$# non-option arguments"
$CDKSETUP
$TERRAFORMSETUP
$CREATESECONDLANG
touch .nojekyll
git add -A docs/
git add .github/
git add .nojekyll
exit
done

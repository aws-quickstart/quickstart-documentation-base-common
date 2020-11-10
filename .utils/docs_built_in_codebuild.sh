#!/bin/bash -e
# This file is meant to be the functional equalivent of the github actions workflow.
#
# // 5 env vars are required to use this.
#   - DOCBUILD_BOILERPLATE_S3_BUCKET
#       This defines the S3 bucketwhere a zip'd copy of *this repo* is located.
#         Example Value: "my-bucket-name-here"
#   - DOCBUILD_BOILERPLATE_S3_KEY
#       This defines the S3 Object key for the above-mentioned ZIP file.
#         Example Value: /path/to/my/file.zip
#   - DOCBUILD_CONTENT_S3_BUCKET
#     This defines the S3 bucket where a zip'd copy of repo to build is located.
#       (can be the same bucket)
#       Example value: "my-bucket-name-here"
#   - DOCBUILD_CONTENT_S3_KEY
#     This is the key where a ZIP of your content repo is located.
#       Example Value: "/path/to/my/other_file.zip"
#   - DOCBUILD_DESTINATION_S3_BUCKET
#        Bucket to upload the generated content to.
#   - DOCBUILD_DESTINATION_S3_KEY
#        S3 Key prefix for the generated content
#   - GITHUB_REPOSITORY
#        Easy identifier of the project that documentation is being built for.
#         - EX: jim-jimmerson/foobar
#       
#
#
# Structure
# <project repo> --- Content repo is unzipped.
#     docs/boilerplate   -- Boilerplate repo is unzipped here.

function upload_preview_content(){
  aws s3 sync --delete ${WORKING_DIR} ${DOCBUILD_DESTINATION_S3} --cache-control max-age=0,no-cache,no-store,must-revalidate
}

function create_upload_ghpages_branch_archive(){
  zip ${DL_DIR}/gh-pages.zip -r .
  aws s3 cp ${DL_DIR}/gh-pages.zip ${DOCBUILD_DESTINATION_S3}
}

DL_DIR=$(mktemp -d)
WORKING_DIR=$(mktemp -d)
echo "${DOCBUILD_BOILERPLATE_S3}"
echo "${DOCBUILD_CONTENT_S3}"
aws s3 cp ${DOCBUILD_BOILERPLATE_S3} ${DL_DIR}/boilerplate.zip
aws s3 cp ${DOCBUILD_CONTENT_S3} ${DL_DIR}/content.zip

unzip ${DL_DIR}/content.zip -d ${WORKING_DIR}
rm -rf ${WORKING_DIR}/docs/boilerplate
unzip ${DL_DIR}/boilerplate.zip -d ${WORKING_DIR}/docs/boilerplate

cd ${WORKING_DIR}
./docs/boilerplate/.utils/generate_dynamic_content.sh
set -x
./docs/boilerplate/.utils/build_docs.sh
set +x

if [ "${DOCBUILD_PROD}" == "true" ]; then
  create_upload_ghpages_branch_archive
else
  upload_preview_content
fi

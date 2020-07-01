FROM python:3.8-buster
RUN pip install cfn-lint --no-cache-dir
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

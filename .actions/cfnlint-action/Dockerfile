FROM python:3.8-alpine
RUN pip install cfn-lint --no-cache-dir
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

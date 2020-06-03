#!/bin/sh
asciidoctor --backend=html5 -o index.html -a allow-uri-read --doctype=book -a toc2 docs/index.adoc

#!/bin/bash

mkdir -p build
mkdir -p tempdoc/+GAMSTransfer
cp src/*.m tempdoc/+GAMSTransfer

(cat doc/Doxyfile && \
    echo "PROJECT_NUMBER=0.4.0"; \
    echo "INPUT=tempdoc/+GAMSTransfer doc/main.dox doc/getting_started.dox doc/container.dox doc/symbols.dox doc/records.dox"; \
    echo "OUTPUT_DIRECTORY=build/doc"; \
    echo "FILTER_PATTERNS=*m=ext/doxymatlab/m2cpp.pl"; \
    echo "LAYOUT_FILE=doc/DoxygenLayout.xml"; \
    echo "IMAGE_PATH=doc"; \
    echo "HTML_HEADER=doc/header.html"; \
    echo "HTML_EXTRA_STYLESHEET=ext/doxygen-awesome-css/doxygen-awesome.css \
        ext/doxygen-awesome-css/doxygen-awesome-sidebar-only.css \
        ext/doxygen-awesome-css/doxygen-awesome-sidebar-only-darkmode-toggle.css"; \
    echo "HTML_EXTRA_FILES=ext/doxygen-awesome-css/doxygen-awesome-darkmode-toggle.js"; \
    ) | doxygen -

rm -rf tempdoc

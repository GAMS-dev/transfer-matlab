#!/bin/bash

mkdir -p tempdoc/+GAMSTransfer
cp src/*.m tempdoc/+GAMSTransfer

(cat doc/Doxyfile && \
    echo "PROJECT_NUMBER=0.2.0"; \
    echo "INPUT=tempdoc/+GAMSTransfer doc/main.dox doc/getting_started.dox doc/manual.dox"; \
    echo "FILTER_PATTERNS=*m=ext/doxymatlab/m2cpp.pl"; \
    echo "LAYOUT_FILE=doc/DoxygenLayout.xml"; \
    echo "HTML_HEADER=doc/header.html"; \
    echo "HTML_EXTRA_STYLESHEET=ext/doxygen-awesome-css/doxygen-awesome.css \
        ext/doxygen-awesome-css/doxygen-awesome-sidebar-only.css \
        ext/doxygen-awesome-css/doxygen-awesome-sidebar-only-darkmode-toggle.css"; \
    echo "HTML_EXTRA_FILES=ext/doxygen-awesome-css/doxygen-awesome-darkmode-toggle.js"; \
    ) | doxygen -

rm -rf tempdoc

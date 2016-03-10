#!/bin/bash

cd `dirname $0`

rm -rf Release && mkdir -p Release/Build && cd $_
cmake -DPRODUCTION_MODE:BOOL=TRUE ../../Sources && time make -j4
cpack

mv *.zip ..

cd ..
rm -rf Build
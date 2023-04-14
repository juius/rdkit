#!/bin/bash

INSTALL_DIR=`pwd`

echo "Setting environment variables..."
export RDBASE=$INSTALL_DIR/rdkit
export PYTHONPATH=$RDBASE:$PYTHONPATH
export LD_LIBRARY_PATH=${RDBASE}/lib:${CONDA_PREFIX}/lib:${LD_LIBRARY_PATH}
export QT_QPA_PLATFORM='offscreen'
export DYLD_FALLBACK_LIBRARY_PATH=${RDBASE}/lib

echo "Building RDKit..."
mkdir build && cd build
cmake -DPYTHON_INCLUDE_DIR="$CONDA_PREFIX/include/python3.9/" \
-DPYTHON_NUMPY_INCLUDE_PATH="$(python -c 'import numpy ; print(numpy.get_include())')" \
-DPy_ENABLE_SHARED=1 \
-DRDK_INSTALL_INTREE=ON \
-DRDK_INSTALL_STATIC_LIBS=OFF \
-DRDK_INSTALL_INTREE=OFF \
-DRDK_BUILD_CPP_TESTS=ON \
-DRDK_BUILD_PYTHON_WRAPPERS=ON \
-DRDK_BUILD_YAEHMOP_SUPPORT=ON \
-DRDK_BUILD_XYZ2MOL_SUPPORT=ON \
-DRDK_BUILD_CAIRO_SUPPORT=ON \
-DRDK_BUILD_INCHI_SUPPORT=ON \
-DRDK_BUILD_FREESASA_SUPPORT=ON \
-DBOOST_ROOT="$CONDA_PREFIX" \
-DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX \
-DINCHI_URL=https://rdkit.org/downloads/INCHI-1-SRC.zip \
-DBoost_NO_SYSTEM_PATHS=ON \
-DBoost_NO_BOOST_CMAKE=TRUE \
-DRDK_BOOST_PYTHON3_NAME="python39" \
..

read -r -p "Continue to installing RDKit? [Y/n] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(no|n)$ ]]
then
    exit 1
fi
echo "Installing..."
make install -j 16
echo "RDKit installation complete"

read -r -p "Continue to run tests [Y/n] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(no|n)$ ]]
then
    exit 1
fi
echo "Running tests..."
ctest -j 16 --output-on-failure

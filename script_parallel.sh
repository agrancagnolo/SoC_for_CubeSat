#!/bin/sh
#########################################
# REQUISITES TO RUN THIS SCRIPT
#########################################
# 1) Have sudo permition and execution permision on this scipt.
#     * In order to execute this script you may put on the terminal:
#	+ $ chmod +x script_parallel.sh
#	+ $ ./script_parallel.sh 
#
# 2) Download Source codes: (Recomended by Xyce Developers)
#     * https://xyce.sandia.gov/downloads/source-code/ (If needed Sign Up whit an email)
#     * https://github.com/trilinos/Trilinos/releases/tag/trilinos-release-12-12-1/   ( Source code (tar.gz) )
#     * Or you can use a repository created to cointain this two files with one of the the next links:
#	+ HTTPS: https://github.com/IvoGC/downloads_needed_XYCE.git
#	+ SSH:	 git@github.com:IvoGC/downloads_needed_XYCE.git 

# 3) This install would create one directory on the $PWD called Xyce_PB containing:
#     * Downloads 	Contains the .tar files
#     * XyceLibs/Parallel (contains trilinos build for parallel build)
#     * Trilinos12.12 (contains Trilinos 12.12 Version)
#     * Xyce_configure (cointains the cofiguration to perfomr the parallel build)
#     * Xyce_parallel_build (the path to the parallel build)
#     * XyceInstall/Parallel (installation path of Parallel Xyce)

# This is in case you have to redefine your home directory
#########################################
# PREPARE THE REPOSITORY
#########################################
mkdir $PWD/Xyce_PB

INSTALL_DIR=$PWD/Xyce_PB

cd $INSTALL_DIR
mkdir $INSTALL_DIR/XyceLibs
mkdir $INSTALL_DIR/XyceLibs/Parallel

#########################################
# DOWNLOAD COMPRESED FILES
#########################################

sudo apt-get install git-lfs
git clone https://github.com/IvoGC/downloads_needed_XYCE.git Downloads
cd $INSTALL_DIR/Downloads 
git lfs install
cd $INSTALL_DIR

#########################################
# INSTALL PREREQUISITE LIBRARIES
#########################################
sudo apt-get install gcc g++ gfortran make cmake bison flex libfl-dev libfftw3-dev libsuitesparse-dev libblas-dev liblapack-dev libtool 
# IF extracted from github repositories you need to execute these lines
#sudo apt-get install autoconf automake git 
# if builind parallel version of Xyce 
sudo apt-get install libopenmpi-dev openmpi-bin

#########################################
# INSTALL TRILINOS-12-12-1
#########################################

# Xyce is not guaranteed to build properly with other versions of Trilinos.

# DOWNLOAD SOURCE CODE FROM: https://github.com/trilinos/Trilinos/releases/tag/trilinos-release-12-12-1/

mkdir $INSTALL_DIR/Trilinos12.12
cd $INSTALL_DIR/Trilinos12.12
# Change the trilininos.tar path to unpack this compresed file
tar xzf $INSTALL_DIR/Downloads/Trilinos-trilinos-release-12-12-1.tar.gz

#########################################
# BUILDING TRILINOS FOR XYCE PARALLEL
#########################################

# Invoke CMake specifying all the required parameters

SRCDIR=$INSTALL_DIR/Trilinos12.12/Trilinos-trilinos-release-12-12-1
ARCHDIR=$INSTALL_DIR/XyceLibs/Parallel
FLAGS="-O3 -fPIC"
cmake \
-G "Unix Makefiles" \
-DCMAKE_C_COMPILER=mpicc \
-DCMAKE_CXX_COMPILER=mpic++ \
-DCMAKE_Fortran_COMPILER=mpif77 \
-DCMAKE_CXX_FLAGS="$FLAGS" \
-DCMAKE_C_FLAGS="$FLAGS" \
-DCMAKE_Fortran_FLAGS="$FLAGS" \
-DCMAKE_INSTALL_PREFIX=$ARCHDIR \
-DCMAKE_MAKE_PROGRAM="make" \
-DTrilinos_ENABLE_NOX=ON \
  -DNOX_ENABLE_LOCA=ON \
-DTrilinos_ENABLE_EpetraExt=ON \
  -DEpetraExt_BUILD_BTF=ON \
  -DEpetraExt_BUILD_EXPERIMENTAL=ON \
  -DEpetraExt_BUILD_GRAPH_REORDERINGS=ON \
-DTrilinos_ENABLE_TrilinosCouplings=ON \
-DTrilinos_ENABLE_Ifpack=ON \
-DTrilinos_ENABLE_Isorropia=ON \
-DTrilinos_ENABLE_AztecOO=ON \
-DTrilinos_ENABLE_Belos=ON \
-DTrilinos_ENABLE_Teuchos=ON \
-DTrilinos_ENABLE_COMPLEX_DOUBLE=ON \
-DTrilinos_ENABLE_Amesos=ON \
 -DAmesos_ENABLE_KLU=ON \
-DTrilinos_ENABLE_Amesos2=ON \
 -DAmesos2_ENABLE_KLU2=ON \
 -DAmesos2_ENABLE_Basker=ON \
-DTrilinos_ENABLE_Sacado=ON \
-DTrilinos_ENABLE_Stokhos=ON \
-DTrilinos_ENABLE_Kokkos=ON \
-DTrilinos_ENABLE_Zoltan=ON \
-DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=OFF \
-DTrilinos_ENABLE_CXX11=ON \
-DTPL_ENABLE_AMD=ON \
-DAMD_LIBRARY_DIRS="/usr/lib" \
-DTPL_AMD_INCLUDE_DIRS="/usr/include/suitesparse" \
-DTPL_ENABLE_BLAS=ON \
-DTPL_ENABLE_LAPACK=ON \
-DTPL_ENABLE_MPI=ON \
$SRCDIR
# INSTALL THE TRILINOS FOR PARALLEL XYCE

make
make install
cd $INSTALL_DIR

#########################################
# DOWNLOAD & UNPACK Xyce SOURCE CODE
#########################################

# Downloading from the web site is the RECOMENDED DOWNLOAD METHOD
# https://xyce.sandia.gov/downloads/source-code/ (CHECK THE  VERSION )

mkdir $INSTALL_DIR/Xyce_configure
cd $INSTALL_DIR/Xyce_configure
tar xzf $INSTALL_DIR/Downloads/Xyce-7.8.tar.gz
cd $INSTALL_DIR

# NOTE: unsing another version change Xyce-7.8 to Xyce-x.x to new version

#########################################
# BUILD Xyce Parallel
#########################################

mkdir $INSTALL_DIR/Xyce_parallel_build
cd $INSTALL_DIR/Xyce_parallel_build
# Invoke CMake specifying all the required parameters
$INSTALL_DIR/Xyce_configure/Xyce-7.8/configure \
CXXFLAGS="-O3" \
ARCHDIR="$INSTALL_DIR/XyceLibs/Parallel" \
CPPFLAGS="-I/usr/include/suitesparse" \
--enable-mpi \
CXX=mpicxx \
CC=mpicc \
F77=mpif77 \
--enable-stokhos \
--enable-amesos2 \
--prefix=$INSTALL_DIR/XyceInstall/Parallel

# INSTALL PARALLEL XYCE
make
sudo make install
cd $INSTALL_DIR/..
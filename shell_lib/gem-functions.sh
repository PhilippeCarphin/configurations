# iris_install_prefix=/home/phc001/Repositories/gitlab.science.gc.ca/RPN-SI/iris/localinstall

# Assume that iris in installed in the subdirectory 'localinstall' of the iris
# source code repository.
export IRIS_SOURCE_DIR=$(repos -get-dir iris)
export IRIS_ROOT=${IRIS_SOURCE_DIR}/localinstall
# Changing this because JP has changed his librmn to the new one where
# the header files are in 'include/rmn/...' instead of in 'include/...'
# So I copied his build of georef and changed it.
# export GEOREF_ROOT=${iris_ssm_dev}/workspace/georef \
setup_root_dirs(){
    # local iris_ssm_dev=/home/ords/cmdd/cmds/nil000/ssm
    local jp_package_dir=/home/ords/cmdd/cmds/nil000/ssm/workspace
    # When georef needed an #include <rmn.h> to be changed to #include <rmn/rmn.h>
    # or something:
    # export GEOREF_ROOT=${HOME}/ords/georef
    export GEOREF_ROOT=${jp_package_dir}/georef
    export RMN_ROOT=${jp_package_dir}/rmn
    export APP_ROOT=${jp_package_dir}/App
    export VGRID_ROOT=${jp_package_dir}/vgrid
    export TDPACK_ROOT=${jp_package_dir}/tdpack
}

################################################################################
# Setup the environment for configuring, building and running Iris
################################################################################
function p.setup-iris(){
    p.setup-intel
    p.setup-iris-ld-library-path
}

################################################################################
# Runs cmake command for Iris with various -D
################################################################################
function p.cmake-iris()
{
    cmd='cmake
        -Drmn_ROOT=${RMN_ROOT}
        -Dgeoref_ROOT=${GEOREF_ROOT}
        -DCMAKE_INSTALL_PREFIX=${IRIS_ROOT}'
    if [[ "$1" == --app ]] ; then
        cmd+=' -DApp_ROOT=${APP_ROOT}'
        shift
    fi
    cmd+=' "$@"'
    printf "\033[1;32m%s\033[0m\n" "$(eval echo $cmd)"
    eval $cmd
}

function p.setup-intel(){
    local ci_env_dir=/home/phc001/Repositories/gitlab.science.gc.ca/RPN-SI/ci-env
    source "${ci_env_dir}/latest/rhel-8-icelake-64/inteloneapi-2022.1.2.sh"
    complete -o default source .
}

# Note: Also used in p.setup-gem-iris
function p.setup-iris-ld-library-path(){
    setup_root_dirs
    # export LD_LIBRARY_PATH=${APP_ROOT}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    export LD_LIBRARY_PATH=${RMN_ROOT}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    export LD_LIBRARY_PATH=${VGRID_ROOT}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    export LD_LIBRARY_PATH=${GEOREF_ROOT}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    export LD_LIBRARY_PATH=${TDPACK_ROOT}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
}

################################################################################
# I like to make sure that things work with a fresh clone pretty often
# out of paranoia
################################################################################
function p.clone-gem(){
    git clone -b wip-use-iris --recursive git@gitlab.science.gc.ca:RPN-SI/GEM "$@"
}


################################################################################
# Setup the environment for configuring, building and running GEM
# NOTE: Defines the GEM_WORK variable which is used as the CMAKE_INSTALL_PREFIX
################################################################################
function p.setup-gem(){

    if [[ -n ${PHIL_GEM_SETUP_DONE} ]] ; then
        echo "PHIL_GEM_SETUP_DONE=${PHIL_GEM_SETUP_DONE}: GEM setup already done skipping"
        return 0
    fi

    # Creates a link :/gem-dbase pointing to some data files
    if ! scripts/link-dbase.sh ; then
        printf "${FUNCNAME[0]}: \033[1;33mWARNING\033[0m: scripts/link-dbase.sh failed\n"
        echo "    ... ignoring because it is probably the leaked result of an '[ condition ] && do_x' where the condition is false"
        # return 1
    fi

    # Loads various packages using r.load.dot
    # Sources .common_setup which sets some environment variables
    #       GEM_ARCH, GEM_DIR, GEM_GIT_DIR, GEM_WORK,
    #       ATM_MODEL_DFILES, AFSISIO, TMPDIR
    # and adds the following directories to $PATH
    #       ${repo_root}/scripts
    #       ${GEM_WORK}/bin
    if ! source .eccc_setup_intel ; then
        echo "${FUNCNAME[0]} ERROR: scripts/link-dbase.sh failed"
        return 1
    fi


    if ! [ -d ${GEM_WORK} ] ; then
        # NOTE: This deletes the ${GEM_WORK} directory and then creates it
        #       I want to be able to use this function to ensure environment
        #       setup is done in p.run-gem.
        #       I think that this file needs to be run IFF ${GEM_WORK} doesn't exist
        source .initial_setup || return 1
    fi
    export PHIL_GEM_SETUP_DONE=yep
}


################################################################################
# Calls the gem-setup function and adds things to LD_LIBRARY_PATH
# for iris to be able to run
################################################################################
function p.setup-gem-iris(){
    if [[ -n ${PHIL_GEM_IRIS_SETUP_DONE} ]] ; then
        echo "PHIL_GEM_IRIS_SETUP_DONE=${PHIL_GEM_IRIS_SETUP_DONE}: GEM-iris setup already done, skipping"
        return 0
    fi

    if ! p.setup-gem ; then
        echo "${FUNCNAME[0]} ERROR: p.setup-gem failed" >&2
        return 1
    fi

    if ! p.setup-iris-ld-library-path ; then
        echo "${FUNCNAME[0]} ERROR: p.setup-iris-ld-library-path failed" >&2
        return 1
    fi

    export PHIL_GEM_IRIS_SETUP_DONE=yup
}

function p.load_sys_gem(){
    . r.load.dot eccc/mrd/rpn/MIG/GEM/x/5.1-u2.1-rc1
}

################################################################################
# Runs cmake command for GEM with various -D
# Note: It has all the same -DX_ROOT as p.cmake-iris with the
#       addition of -Diris_ROOT=${IRIS_ROOT}
# Note: Certain things rely on using ${GEM_WORK} as the
#       install prefix
################################################################################
function p.cmake-gem-makefile(){
    setup_root_dirs
    cmd='cmake
        -DWITH_SYSTEM_RPN=FALSE
        -Diris_ROOT=${IRIS_ROOT}
        -Dgeoref_ROOT=${GEOREF_ROOT}
        -DCMAKE_INSTALL_PREFIX=${GEM_WORK}'

    if [[ "$1" == --app ]] ; then
        cmd+=' -DApp_ROOT=${APP_ROOT}'
        shift
    fi
    cmd+=' "$@"'
    printf "\033[1;32m%s\033[0m\n" "$(eval echo $cmd)"
    eval $cmd
}

function p.cmake-gem-sys-rpn(){
    cmd='cmake
        -DWITH_SYSTEM_RPN=TRUE
        -Diris_ROOT=${IRIS_ROOT}
        -Dgeoref_ROOT=${GEOREF_ROOT}
        -DApp_ROOT=${APP_ROOT}
        -DCMAKE_INSTALL_PREFIX=${GEM_WORK}
        "$@"'
    printf "\033[1;32m%s\033[0m\n" "$(eval echo $cmd)"
    eval $cmd
}



################################################################################
# Follow first instructions for running GEM in readme
################################################################################
function p.run-gem-iris(){

    if ! on_compute_node ; then
        echo "${FUNCNAME[0]} ERROR: Only use this function on a compute node" >&2
        return 1
    fi

    (
        make -j work
        p.setup-gem-iris

        if [[ "${1}" == "iris" ]] ; then
            export GEM_MPIRUN_USE_MPIRUN_DIRECTLY='yes'
            export GEM_MPIRUN_WITH_IRIS_MAIN='yes'
            # IRIS_ROOT should already be defined
            export IRIS_REPO=/home/phc001/Repositories/gitlab.science.gc.ca/RPN-SI/iris
            # Exact instructions from the README for running GEM
        fi
        cd $GEM_WORK
        runprep.sh -dircfg ./configurations/GEM_cfgs_LU_FISL_H
        runmod.sh -dircfg ./configurations/GEM_cfgs_LU_FISL_H
    )
}


function on_compute_node(){
    [[ $(hostname) == ppp[56]cn* ]]
}

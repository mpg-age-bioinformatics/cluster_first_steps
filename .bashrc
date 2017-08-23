echo "Reading ~/.bashrc ..."
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# If you wanna have environment modules in your jupyterhub notebook you should add the below
# Add environment module
module() { eval `/usr/bin/modulecmd bash $*`; }
export -f module

MODULESHOME=/usr/share/Modules
export MODULESHOME

if [ "${LOADEDMODULES:-}" = "" ]; then
  LOADEDMODULES=
  export LOADEDMODULES
fi

if [ "${MODULEPATH:-}" = "" ]; then
  MODULEPATH=`sed -n 's/[       #].*$//; /./H; $ { x; s/^\n//; s/\n/:/g; p; }' ${MODULESHOME}/init/.modulespath`
  export MODULEPATH
fi

if [ ${BASH_VERSINFO:-0} -ge 3 ] && [ -r ${MODULESHOME}/init/bash_completion ]; then
 . ${MODULESHOME}/init/bash_completion
fi

source /beegfs/common/software/2017/age-bioinformatics.2017.only.rc
module load slurm



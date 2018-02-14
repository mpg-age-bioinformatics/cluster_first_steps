## Table of Contents

[General](#general)

[SLURM](#slurm-simple-linux-utility-for-resource-management)

[Modules](#environment-modules-project)

[Shifter](#shifter)

[Databases and reference genomes](#databases-and-reference-genomes)

[Data](#data)

[RStudio-server](#rstudio-server)

[JupyterHub](#jupyterhub)

[DockerHub](#dockerhub)

## General

If you would like to get access to the local cluster at the MPI-AGE
please mail bioinformatics@age.mpg.de.

An introduction to HPC and SLURM can be found [here](http://github.com/mpg-age-bioinformatics/mpg-age-bioinformatics.github.io/blob/master/tutorials/RemoteServers.pdf).

Once you have been given access you can login to one of the 2 head nodes with:

```bash
ssh -XY UName@amalia
```

or

```bash
ssh -XY UName@amaliax
```

Please note that while `amalia` is a virtual machine (with 8 cores, 32 GB RAM, no infiniband connection, and no X forwarding)
`amaliax` is a blade node (with 40 cores, 250 GB RAM, infiniband network, and X forwarding).

The first time you login you should download the following `.bashrc` and `.bash_profile` and source them:

```bash
cd ~
wget https://raw.githubusercontent.com/mpg-age-bioinformatics/cluster_first_steps/master/.bashrc
wget https://raw.githubusercontent.com/mpg-age-bioinformatics/cluster_first_steps/master/.bash_profile
source .bashrc
source .bash_profile
```

## SLURM, Simple Linux Utility for Resource Management 

```bash
# show the partitions 
sinfo 

# show information on nodes 
sinfo -N -O partitionname,nodehost,cpus,cpusload,freemem,memory

# show the queue
squeue 

# show the queue for a user
squeue -u <user name>

# show information on a job
scontrol show job <job id>

# show information on a partition
scontrol show partition <parition name>

# show information on a node
scontrol show node <node name>

# start and interactive bash session
srun --pty bash

# submit a job
sbatch -p <partition> --cpus-per-task=<n cpus> --mem=<n>gb -t <hours>:<minutes>:<seconds> -o <stdout file> <script>  

# submit a job3 after job1 and job2 are successfully ready
job1=$(sbatch --parsable <script1>)
job2=$(sbatch --parsable <script2>)
sbatch -d afterok:${job1}:${job2} <script3>

# attach to a running job and run a command
srun --jodib <JOBID> --pty <command>

# cancel a job
scancel <job id>

# cancel all jobs for user
scancel -u <user name>

# change the partitions of a pending job
scontrol update job <job id> partition=<partition1>,<partition2>,<partition3>

# change the partition and reserved nodes where node list has the form bioinf-blc-[02,27-28]
scontrol update job <job id> partition=<partition1>,<partition2>,<partition3> nodelist=<node list>
```

Submissions wihtout arguments specifications will result in `-p blade --cpus-per-task=2` and a time limit of 2 weeks.

For large job submissions please use the **blade** partition. For large jobs submission over large periods (eg. more than a week) please use the **long** partition. 

Feel free to use all partitions (ie. also the **himem** and **hugemem** partitions) for large job submissions as well provided you can easely make these two partitions free on request of other users (eg. if you are submiting short jobs this should be easely achievable by using `sview` to modify the target partitions of your jobs).

When submitin jobs with `sbatch` you can also include SLURM parameters inside the script ie.:
```
#!/bin/bash
#SBATCH -p <partition> 
#SBATCH --cpus-per-task=<n cpus> 
#SBATCH --mem=<n>gb 
#SBATCH -t <hours>:<minutes>:<seconds> 
#SBATCH -o <stdout file> 

<code>
```
and then run the script with `sbatch <script>`.

## Environment Modules Project

A centralized software system.
The modules system loads software (version of choice) and changes environment 
variables (eg. LD_LIBRARY_PATH).

```bash
# show available modules
module avail			

# show a description of the SAMtools module
module whatis SAMtools	

# show environment changes for SAMtools
module show SAMtools

# load SAMtools
module load SAMtools		

# list all loaded modules
module list	  

# unload the SAMtools module
module unload SAMtools	

# unload all loaded modules
module purge  			
```
Jupyterhub and R-Studio Server are using the R version 3.3.2 from the module environment. For this you have to `source /software/2017/age-bioinformatics.2017.only.rc` and `module load rlang`.

## Shifter

*! This sechtion is under development - please contact us if you wish to use Shifter !*

Shifter enables container images for HPC. In a nutshell, Shifter allows an HPC system to efficiently and safely allow end-users to run a [docker](http://www.docker.com) image.

**What is a Container?**
Containers are a way to package software in a format that can run isolated on a shared operating system. Unlike VMs (Virtual Machines), containers do not bundle a full operating system - only libraries and settings required to make the software work are needed. This makes for efficient, lightweight, self-contained systems and guarantees that software will always run the same, regardless of where it’s deployed. (source: [docker.com](http://www.docker.com)).

An introduction to docker and how to generate your own images can be found [here](http://github.com/mpg-age-bioinformatics/mpg-age-bioinformatics.github.io/blob/master/tutorials/reproducible_multilang_workflows_with_jupyter_on_docker ). More information on how to build docker images and best practices for writing Dockerfiles can be found [here](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/) and [here](https://docs.docker.com/engine/reference/builder/), respectively.

```
# load the required module
module load shifter/latest

# Pull and image (administrators only)
shifterimg pull docker/ubuntu:15.10

# List available images (administrators only)
shifterimg images

# List available images (all)
shifterls

# Get an interactive shell and check you are in the intended image
shifter --image=ubuntu:15.10 bash -login
cat /etc/lsb-release 
```
You expect to see the following output:
```
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=15.10
DISTRIB_CODENAME=wily
DISTRIB_DESCRIPTION="Ubuntu 15.10"
```
You can also use it with SLURM. Consider the folowing script named `shifter.test.sh`:
```
#!/bin/bash
#SBATCH -o shifter.out

shifter --image=docker:ubuntu:15.10 cat /etc/lsb-release
```
Now run it (ie. `sbatch shifter.test.sh`) and check the contents of `shifter.out`.

Please visit our software_docker [page](https://github.com/mpg-age-bioinformatics/software_docker#software-container) if you wish to use the image containing all software currently in use `mpgagebioinformatics/bioinformatics_software`.

Attention, you might need to:
```bash
unset PYTHONHOME PYTHONUSERBASE PYTHONPATH 
module unload rlang
```
before running `shifter`. This is automaticaly done when running the `mpgagebioinformatics/bioinformatics_software` if you use the `.bashrc` provided above.

**Running a script with shifter using the `mpgagebioinformatics/bioinformatics_software` image:**

- example script: `test.sh`
```bash
#!/bin/bash
source ~/.bashrc

module load rlang python

which python

python << EOF
print "This is python"
EOF

which R

Rscript -e "print('This is R')"
```
- running the script
```bash
chmod +x test.shifter.sh
shifter \
    --image=mpgagebioinformatics/bioinformatics_software:v1.0.1 \   
    ./test.sh
```

**Running a scipt over shifter on slurm:**

- example script: `test.slurm.sh`
```bash
#!/bin/bash
#SBATCH --cpus-per-task=18
#SBATCH --mem=15gb
#SBATCH --time=5-24 
#SBATCH -p blade
#SBATCH -o test.shifter.out

shifter –-image=mpgagebioinformatics/bioinformatics_software:v1.0.1 << SHI
#!/bin/bash

source ~/.bashrc 

module load rlang python

which python

python << EOF
print "This is python"
EOF

which R

Rscript -e "print('This is R')"

SHI
```
- running the script over slurm
```bash
chmod +x test.slurm.sh
sbatch test.slurm.sh
```
- check the output
```bash
cat test.shifter.out
```

**Example for automation over a batch of jobs:**

- example script: `automation.slurm.shifter.sh`
```bash
#!/bin/bash
cd ~/project/raw_data			
for f in $(ls *.fastq); 
   do  rm ~/project/slurm_logs/${f}.*.out

   sbatch --cpus-per-task=18 --mem=15gb --time=5-24 \
   -p blade -o ~/project/slurm_logs/${f}.%j.out ~/project/tmp/${f}.sh <<EOF
#!/bin/bash
shifter –image=mpgagebioinformatics/bioinformatics_software:v1.0.1 << SHI	
#!/bin/bash
source ~/.bashrc 
module load bwa
cd ~/project/raw_data			
bwa mem –T 18 ${f}	
SHI			
EOF

done			
exit
```
- running the script
```bash
chmod +x automation.slurm.shifter.sh
./automation.slurm.shifter.sh
```

## Databases and reference genomes

We mantain a variety of databases and indexed genomes. Please contact us if you would require any database to be updated, genome reference added, or additional support on this.

```bash
cluster:/beegfs/common/databases$ tree -L 1
.
├── BLAST
├── DATABASE_VERSION_LIST
├── GOMo
├── hmdb
├── miR_targets
├── Motif
├── MSigDB
├── new
├── Pfam
├── README
├── SequencingAdapters
├── SwissProt
└── UniRef90
```
```bash
cluster:/beegfs/common/genomes$ tree -L 2
.
├── adapters
│   ├── All.fasta
│   └── TruSeqAdapters.txt
├── caenorhabditis_elegans
│   ├── 83
│   ├── 85
│   ├── WBcel235_79
│   ├── WBcel235_80
│   └── WBcel235_81
├── drosophila_melanogaster
│   ├── 83
│   ├── BDGP6_80
│   └── BDGP6_81
├── homo_sapiens
│   ├── 83
│   ├── GRCh38_80
│   └── GRCh38_81
├── mus_musculus
│   ├── 83
│   ├── GRCm37_mm9
│   ├── GRCm38_79
│   ├── GRCm38_80
│   └── GRCm38_81
└── saccharomyces_cerevisiae
    ├── 82
    └── 83
```

```bash
cluster:..mmon/genomes/homo_sapiens/83$ ls
alt_bowtie2      alt_tophat2_cuffcompare      original.abinitio.gtf              original.toplevel.fa      primary_assembly_star_2.4.1d          toplevel_bwa
alt_bwa          BUILD_GRCh38_RELEASE_83      original.alt.fa                    original.toplevel.fa.fai  primary_assembly_tophat2              toplevel_hisat
alt_hisat        chromosomes                  original.chr.gtf                   primary_assembly_bowtie2  primary_assembly_tophat2_cuffcompare  toplevel_hisat2
alt_hisat2       cuffcompare.gtf              original.chr_patch_hapl_scaff.gtf  primary_assembly_bwa      README_fa                             toplevel_star_2.4.1d
alt_star_2.4.1d  cuffcompare.results.tar.bz2  original.gtf                       primary_assembly_hisat    README_gtf                            toplevel_tophat2
alt_tophat2      log                          original.primary_assembly.fa       primary_assembly_hisat2   toplevel_bowtie2                      toplevel_tophat2_cuffcompare
```
   
## Data

Data stored on the cluster is not backed up. You are responsible for the backup of your data into a different file system.

#### Short Explanation

You can use many clients to copy your files to the cluster-filesystem beegfs.
The clients needs to be able to use scp. scp means secure copy. That mean that your files are crypted during the copy process.
We would recommend using filezilla.
This Gui is available most known Operating systems, like Windows, Linux or OS-X (if you have a MAC).

#### Using scp

eg. transfer file from the server

```bash
# on the server side
scp </path/to/file> UName@<IP_ADDRESS>:~/Desktop
```

or 

```bash
# on your client side
scp UName@amalia:</path/to/file> ~/Desktop
```

transfer data to the server

```bash
# on the client side
scp </path/to/file> UName@amalia:~/
```

#### Filezilla installation instructions for Ubuntu

First install filezilla with the following command:

```bash
sudo apt-get install filezilla
```

Now you have installed the program filezilla.
All you have to do is to create an icon for it:

right click on the desktop and use: Create Launcher

You should name it filezilla

Add **filezilla** into the command window of your Create Launcher window
and **mark it executable**.

After that you should be able to use filezilla.

#### Filezilla installation instructions for OSX

On MacOSX you can download attachment:FileZilla\_3.13.1\_macosx-x86.app.tar.bz2
Go to the **Downloads** folder in the **Finder** app.
Double click the file to extract the archive.
Copy (drag and drop) the extracted file **Filezilla** or **Filezilla.app** to your **Applications** folder.
Double click the icon to start it, or drag it to the Dock.

#### Filezilla installation instructions for Windows

On Windows installers there might be already activated checkboxes for some other software, like the yahoo toolbar.
You should uncheck them.

#### Using FIlezilla and explaining beegfs

beegfs is a cluster filesystem. This filesystem is designed for speed and parallel access. It is not designed as a save filesystem. So if you want to save your results,
you have to move your results to another location.

If you want to connect the cluster with filezilla, then you have to open filezilla.
In filezilla you have to open the site Manager and you have to make an entry like this one (for "Host" please use "amalia" instead of "cluster"):

![site_manager](https://github.com/mpg-age-bioinformatics/cluster_first_steps/blob/master/img/Site_manager.png)
 
Your settings should be the same, but with a different name. You should save the entry.

Then you only have to press the connect button and you have to enter your password. This password will be only saved for the session for security reasons.
Your window will look like this one. There you can drag and drop the files or folders you want to copy.

![copy_data](https://github.com/mpg-age-bioinformatics/cluster_first_steps/blob/master/img/Copy_window.png)

#### Using sshfs

install osxfuse and sshfs on your client (eg. laptop)
osx: http://osxfuse.github.io
linux: `sudo apt-get install sshfs`

on your client, run:

```bash
mkdir ~/cluster_mount
sshfs JDoe@amalia:/beegfs/group_XX ~/cluster_mount
```

## RStudio-server

An RStudio-server connected to the HPC shared file system is available on [https://rstudio.age.mpg.de](https://rstudio.age.mpg.de).

## JupyterHub

A JupyterHub connected to the HPC shared file system is available on [https://jupyterhub.age.mpg.de](https://jupyterhub.age.mpg.de).

*Kernels* : Python/2.7.12; Python/3.6.0; R/3.3.2; ruby/2.4.0 

To use it for the first time make sure the file `~/.jupyter/jupyter_notebook_config.py` has no content or does not exist.

Users can add environment variables to the JupyterHub by making use of their local `.jupyter` config. Eg. Adding `bedtools` to your JupyterHub path:
```bash
mkdir -p ~/.jupyter
vim ~/.jupyter/jupyter_notebook_config.py
```
Contents of the `jupyter_notebook_config.py`:
```python
import os
os.environ["PATH"]="/beegfs/common/software/2017/modules/software/bedtools/2.26.0/bin:"+os.environ["PATH"]
```

The JupyterHub environment can be loaded on the normal `ssh` connection by 
```bash
module load jupyterhub
```

As complete module, jupyterhub has is own *Python2* and *Python3* environment. Thus, if you want to batch *Python* code that you developed on the *JupyterHub* you should make use of the `module load jupyterhub`.

The *R* kernel makes use of the *module rlang/3.3.2*. Thus, if you want to batch *R* code that you developed on the *JupyterHub* you should make use of the `module load rlang`.

The *ruby* kernel makes use of the *module ruby/2.4.0*. Thus, if you want to batch *ruby* code that you developed on the *JupyterHub* you should make use of the `module load ruby/2.4.0`.

**Using the Modules system from within JupyterHub**

If you start a Terminal from Jupyterhub `~/.bashrc` is processed and `~/.profile` not. So if you want to use modules from the terminal add the content of [`.bashrc`](https://github.com/mpg-age-bioinformatics/cluster_first_steps/blob/master/.bashrc) to your `~/.bashrc`.
 
**Running Jupyter over slurm** 

You can also run `jupyter notebook` over *slurm*. If you decide to do this, only the *Python3* kernel will be available. You can install and registers additional kernels for your user if you wish. Contact us if you need help on this.

Before the first usage make sure you download the correct config file:
```bash
cd ~
wget https://raw.githubusercontent.com/mpg-age-bioinformatics/cluster_first_steps/master/jupyter_notebook_config.py
```
Afterwards:
```bash
module load jupyterhub
srun jupyter notebook --config ~/jupyter_notebook_config.py
```
This will default to port 8888. You can also choose an alternative port by for example: 
```bash
srun jupyter notebook --config ~/jupyter_notebook_config.py --port 8989
```

## DockerHub
Using our Dockerhub for docker images wich should not be public available.

Go to https://hub.age.mpg.de and login with your LDAP credentials.

**Namespaces**

Namespaces are like sub folders for the URL where the docker repositorys are in.
Namespaces do have Access rights. You see these rights right beside the Name under Namespaces.
- The lock means only explicit users can access
- Group means all logged in users can access
- Globe means it is shared with the whole world

So you have your personal namespace and you can create new namespaces for special teams and access rights.
Bevor creating namespaces you need a team where you are in and can add members.

The URLs for your Images will look like this: hub.age.mpg.de/namespace/image:version

So in case of a user this could be: hub.age.mpg.de/drosskopp/debian:jessie

You can use these URLs with docker and shifterimg

**Teams**

Under teams you can create such and add users to use these for the rights of namespaces.

**Application Tokens**

If you klick in the upper right on your name you can create applikation tokens.
- PLEASE USE IT.
This is important because if you use your password with the docker command or schifterimg it will be saved in your homefolder or on the serverside.
- So klick: Create new token
- Give it a predictive name
- And use the token that appears after saving in the upper right corner for auth with docker or schifterimg commands

**Use with docker**

Now you can use Docker to push the first image.
- If you dont have a own docker image, get one at docker.io
```bash
- docker pull alpine:latest
```
Than Tag your Image for our registry
```bash
- docker tag alpine:latest hub.age.mpg.de/drosskopp/anyname:version
```
- Login to our registry (use the application token you created)
```bash
docker login hub.age.mpg.de
Username: DRosskopp 
Password: 
	Login Succeeded
```
- Now push your image and inspect it after under repositories in the interface
```bash
docker push hub.age.mpg.de/drosskopp/anyname:version
```

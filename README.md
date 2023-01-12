## Table of Contents

[General](#general)

[SLURM](#slurm-simple-linux-utility-for-resource-management)

[Modules](#environment-modules-project)

[Shifter](#shifter)

[Singularity](#singularity)

[Databases and reference genomes](#databases-and-reference-genomes)

[Data](#data)

[RStudio-server](#rstudio-server)

[JupyterHub](#jupyterhub)

[DockerHub](#dockerhub)

[Selfservice](#selfservice)

## General

If you would like to get access to the local cluster at the MPI-AGE
please mail bioinformatics@age.mpg.de.

An introduction to HPC and SLURM can be found [here](http://github.com/mpg-age-bioinformatics/mpg-age-bioinformatics.github.io/blob/master/tutorials/RemoteServers.pdf).

Once you have been given access you can login to one of the 2 head nodes with:

```bash
ssh -XY UName@c3po
```

or

```bash
ssh -XY UName@r2d2
```

Please note that while `amalia` is a virtual machine (with 8 cores, 32 GB RAM, no infiniband connection, and no X forwarding)
`r2d2` is a blade node (with 40 cores, 250 GB RAM, infiniband network, and X forwarding).

The first time you login you should download the following `.bashrc` and `.bash_profile` and source them:

```bash
cd ~
wget https://raw.githubusercontent.com/mpg-age-bioinformatics/cluster_first_steps/master/.bashrc
wget https://raw.githubusercontent.com/mpg-age-bioinformatics/cluster_first_steps/master/.bash_profile
source .bashrc
source .bash_profile
```

--- 

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

Submissions wihtout arguments specifications will result in `-p hooli --cpus-per-task=2` and a time limit of 2 weeks.

For large job submissions please use the **hooli** partition.

Feel free to use all partitions (ie. also the **bighead** partition) for large job submissions as well provided you can easely make these partition free on request of other users (eg. if you are submiting short jobs this should be easely achievable by using `sview` to modify the target partitions of your jobs).

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

--- 

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

--- 

## Shifter

<details><summary>Shifter has been deprecated. Please use Singularity instead. Click here if you want to know more.</summary> 
<p>

*! This sechtion is under development - please contact us if you wish to use Shifter !*

Shifter enables container images for HPC. In a nutshell, Shifter allows an HPC system to efficiently and safely allow end-users to run a [docker](http://www.docker.com) image.

**What is a Container?**
Containers are a way to package software in a format that can run isolated on a shared operating system. Unlike VMs (Virtual Machines), containers do not bundle a full operating system - only libraries and settings required to make the software work are needed. This makes for efficient, lightweight, self-contained systems and guarantees that software will always run the same, regardless of where it’s deployed. (source: [docker.com](http://www.docker.com)).

An introduction to docker and how to generate your own images can be found [here](http://github.com/mpg-age-bioinformatics/mpg-age-bioinformatics.github.io/blob/master/tutorials/reproducible_multilang_workflows_with_jupyter_on_docker ). More information on how to build docker images and best practices for writing Dockerfiles can be found [here](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/) and [here](https://docs.docker.com/engine/reference/builder/), respectively.

```
# load the required module
module load shifter

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

**Running a script over shifter on slurm:**

- example script: `test.slurm.sh`
```bash
#!/bin/bash
#SBATCH --cpus-per-task=18
#SBATCH --mem=15gb
#SBATCH --time=5-24 
#SBATCH -p hooli
#SBATCH -o test.shifter.out

shifter –-image=mpgagebioinformatics/bioinformatics_software:v1.0.1 /bin/bash << SHI
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
   -p blade -o ~/project/slurm_logs/${f}.%j.out <<EOF
#!/bin/bash
shifter –-image=mpgagebioinformatics/bioinformatics_software:v1.0.1 /bin/bash << SHI	
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

</p>
</details>
	
--- 

## Singularity

Like Shifter, Singularity enables container images for HPC. In a nutshell, Singularity allows end-users to efficiently and safely run a docker image in an HPC system.

An introduction to docker and how to generate your own images can be found [here](http://github.com/mpg-age-bioinformatics/mpg-age-bioinformatics.github.io/blob/master/tutorials/reproducible_multilang_workflows_with_jupyter_on_docker ). More information on how to build docker images and best practices for writing Dockerfiles can be found [here](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/) and [here](https://docs.docker.com/engine/reference/builder/), respectively.

There are a few differences compared to shifter:

Singularity is available without loading a module from environment system.
As opposed to shifter, images are loaded, converted and saved by the user. This means you can manage your images as files.

Example 1:
```
singularity pull bioinformatics_software.v3.0.0.sif  docker://index.docker.io/mpgagebioinformatics/bioinformatics_software:v3.0.0
singularity exec bioinformatics_software.v3.0.0.sif /bin/bash
```

Example 2:

```
✓ DRosskopp@amaliax:~$ singularity pull --docker-login bioinf.sif docker://hub.age.mpg.de/bioinformatics/software:v2.0.7
Enter Docker Username: DRosskopp
Enter Docker Password: 
INFO:    Starting build...
Getting image source signatures
Skipping fetch of repeat blob sha256:f2aa67a397c49232112953088506d02074a1fe577f65dc2052f158a3e5da52e8
Skipping fetch of repeat blob sha256:3f6b9e83e5d6033819db3ba797bbe47f2f076b7f34ec4013ed8b72e8e31ec5d6
Skipping fetch of repeat blob sha256:bf3ecbd09edff2c407c73c9cfe8ac34b6c8a6f51924f85e80a1c16dc60c507ed
Skipping fetch of repeat blob sha256:528d9147306959cbe46d20111957b025a37228d96f1bceb6b43508f84350924e
Skipping fetch of repeat blob sha256:fe6621519f4c795af8befe1ba78f9a063dd35290b7c99cfbcf1609eeb195b905
Skipping fetch of repeat blob sha256:550f7c533e43749d743fb96f5c8668948f994c5a24db9d5626ec10587714596f
Skipping fetch of repeat blob sha256:4819569a7cf047babb2792d4909e044efcddf32ef7b8be41ebfd859454fafcc4
Skipping fetch of repeat blob sha256:61604835e6cd4116d1b8558f920a4a3e0a527e5e177ecaba2f357b095da96c11
Skipping fetch of repeat blob sha256:f536d63a048365fd563f4b1ebf7ff8b4e80d1927381b7d14b3526dac5f662e6f
Skipping fetch of repeat blob sha256:4a5f46f898f5661f2e738165de9d075da9a30e05c431605837f63531e9e443de
Skipping fetch of repeat blob sha256:ed9f07702f7e4360712eb7e76792ce247442b401203c1be83eba634afe14eae6
Skipping fetch of repeat blob sha256:4a7b10854cebbdd9417559fc2dfd6f37968a18f30fb1657562f2076d294af804
Skipping fetch of repeat blob sha256:644fd3174a744f364a3c8a3829457eb268e8e3d52f1cf66c419bdda62bc1e2c1
Skipping fetch of repeat blob sha256:0d88ae9f4ee7d64a265003add40f702170e453fc5b2bd8d7e72a7f211ac32d18
Skipping fetch of repeat blob sha256:5574fcf6b3cb463ee7b283770a12c7bf65784b68aa7b73272c769868be452cdf
Skipping fetch of repeat blob sha256:07931a6d414573af5c7dac37d0432c65fb3ea0728aee087c5dc83eba3ff4e09c
Skipping fetch of repeat blob sha256:84a67f64cd8b812c0155be2990423437ed2fec97296f785b8cbae99ad5de50e7
Skipping fetch of repeat blob sha256:7a54abef2269cfe68932bd905e23fad2b54b625f88f46b98e14c89ca45977c26
Skipping fetch of repeat blob sha256:74f2dec22f78293feba10a84d1c1e6449691541385384659a576f43b3cb81b8f
Skipping fetch of repeat blob sha256:93ed5825f1592aaa497456fdac4d18691b02e2225ea738fc0aff258751d1d06f
Skipping fetch of repeat blob sha256:c3c384cf4584bdda8121ff81d1ca9dc2985237e7d9cfad201982b6d27f3fd7f3
Copying config sha256:1d05af2aa2187192dc817527df50e0c671fdb4fa7491014232e53aa6ea8af7df
 115.00 KiB / 115.00 KiB [==================================================] 0s
Writing manifest to image destination
Storing signatures
INFO:    Creating SIF file...
INFO:    Build complete: bioinf.sif
✓ DRosskopp@amaliax:~$ ls -la bioinf.sif 
-rwxr-xr-x 1 DRosskopp group_bit 5667733504 Oct 28 15:52 bioinf.sif
✓ DRosskopp@amaliax:~$ du -hs bioinf.sif 
5.3G	bioinf.sif
✓ DRosskopp@amaliax:~$ singularity exec bioinf.sif /bin/bash
✓ DRosskopp@amaliax:~$ cat /etc/deb
debconf.conf    debian_version  
✓ DRosskopp@amaliax:~$ cat /etc/debian_version 
9.4
✓ DRosskopp@amaliax:~$ exit
exit
✓ DRosskopp@amaliax:~$ cat /etc/redhat-release 
CentOS Linux release 7.6.1810 (Core) 
✓ DRosskopp@amaliax:~$
```
The full documentation for Singularity is available [here](https://sylabs.io/guides/3.3/user-guide/index.html).

**Downloading images with authentication from [hub.age.mpg.de](https://hub.age.mpg.de):** 

Login to [hub.age.mpg.de](https://hub.age.mpg.de) and generate an encrypted password by clicking on your username
and then Account settings > Generate encrypted password.

Afterwards:
```
export SINGULARITY_DOCKER_USERNAME=<your username>
export SINGULARITY_DOCKER_PASSWORD=<your password>
singularity pull </path/to/image.sif> docker://hub.age.mpg.de/<namespace>/<image name>:<image tag>
```

**Running a script with singularity using the `mpgagebioinformatics/bioinformatics_software` image:**

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
✓ DRosskopp@amaliax:~$ chmod +x test.sh
✓ DRosskopp@amaliax:~$ singularity exec bioinf.sif ./test.sh
/modules/software/python/2.7.15/bin/python
This is python
/modules/software/rlang/3.5.1/bin/R
[1] "This is R"
```

**Running a script over singularity on slurm:**

- example script: `test.slurm.sh`
```bash
#!/bin/bash
#SBATCH --cpus-per-task=18
#SBATCH --mem=15gb
#SBATCH --time=5-24 
#SBATCH -p hooli
#SBATCH -o test.singularity.out

singularity exec bioinf.sif /bin/bash << SHI
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
✓ DRosskopp@amaliax:~$ chmod +x test.slurm.sh
✓ DRosskopp@amaliax:~$ sbatch test.slurm.sh
Submitted batch job 4684802
✓ DRosskopp@amaliax:~$
```
- check the output
```bash
✓ DRosskopp@amaliax:~$ cat test.singularity.out
/modules/software/python/2.7.15/bin/python
This is python
/modules/software/rlang/3.5.1/bin/R
[1] "This is R"
✓ DRosskopp@amaliax:~$
```

**Example for automation over a batch of jobs:**

- example script: `automation.slurm.singularity.sh`
```bash
#!/bin/bash
cd ~/project/raw_data			
for f in $(ls *.fastq); 
   do  rm ~/project/slurm_logs/${f}.*.out

   sbatch --cpus-per-task=18 --mem=15gb --time=5-24 \
   -p blade -o ~/project/slurm_logs/${f}.%j.out <<EOF
#!/bin/bash
singularity exec bioinf.sif /bin/bash << SHI	
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
chmod +x automation.slurm.singularity.sh
./automation.slurm.singularity.sh
```

--- 

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

--- 
 
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
scp UName@c3po.age.mpg.de:</path/to/file> ~/Desktop
```

transfer data to the server

```bash
# on the client side
scp </path/to/file> UName@c3po.age.mpg.de:~/
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
sshfs JDoe@c3po.age.mpg.de:/beegfs/group_XX ~/cluster_mount
```

--- 

## RStudio-server

An RStudio-server connected to the HPC shared file system is available on [https://rstudio.age.mpg.de](https://rstudio.age.mpg.de).

If you got notes like ```note: use option -std=c99 or -std=gnu99 to compile your code``` during installation of R-Modules, please create the files ~/.R/Makevars and ~/.R/3.5.1/Makevars with the content ```CC = gcc -std=c99``` 

**Running R-Studio images over the terminal on the server**

This section describes how to reproduce the R-Studio environment in [https://rstudio.age.mpg.de](https://rstudio.age.mpg.de) on the terminal.

Eg. R-3.6.3

```
amaliax:~$ singularity exec /beegfs/common/singularity/r.3.6.3.sif /bin/bash
amaliax:~$ which R
/usr/local/bin/R
amaliax:~$ R
 > .libPaths()
[1] "/beegfs/group_bit/home/JBoucas/.R/3.6.3/R_LIBS_USER"
[2] "/usr/local/lib/R/site-library"                      
[3] "/usr/local/lib/R/library" 
```

**Running R-Studio images on your laptop**

This section describes how to reproduce the R-Studio installation in [https://rstudio.age.mpg.de](https://rstudio.age.mpg.de) on your local laptop.

```
$ mkdir -p ~/r-age/3.6.3
$ docker run -d -p 8787:8787 -v ~/rstudio-age/:/home/rstudio --name rstudio -e PASSWORD=yourpasswordhere mpgagebioinformatics/rstudio-age:3.6.3
```
You can now access rstudio over http://localhost:8787 username: `rstudio` password: `yourpasswordhere` .

If you wish to run R from the terminal instead you can:
```
$ docker exec --user rstudio -it rstudio R
```

For installing system libraries as root:
```
$ docker exec -it rstudio /bin/bash
```
Please realise that system libraries will be gone once the container is removed.

Stopping the container:
```
$ docker stop rstudio
```

Rmoving the container:
```
$ docker rm rstudio
```

The folders `/beegfs/group_bit/home/<username>/.R/3.6.3/R_LIBS_USER` in amalia are homologous to `~/r-age/3.6.3` in your laptop. You can copy or `rsync` both folders if you want to use libraries accross machines.

--- 

## JupyterHub

A JupyterHub connected to the HPC shared file system is available on [https://jupyterhub.age.mpg.de](https://jupyterhub.age.mpg.de).

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
**Creating conda enviroments with jupyter kernels**

Go to https://jupyterhub.age.mpg.de/ 

File > New > Terminal

Then:
```
mkdir -p ~/.conda/pkgs
export CONDA_PKGS_DIRS=~/.conda/pkgs
conda config --show pkgs_dirs
conda create -n ex
conda activate ex
conda install -c anaconda ipykernel
python -m ipykernel install --user --name ex --display-name "Python (ex)"
```
Restart your server: 

File > Hub Control Panel > Stop My Server 

Logout

Login again and you should see "Python (ex)" in the Notebook as well as Console section of the Launcher.

**Using the jupyterhub image on your local latpop with docker**

```
docker pull mpgagebioinformatics/jupyter-age:latest
mkdir -p ${HOME}/jupyter-age/jupyter/ ${HOME}/jupyter-age/data/
docker run -v ${HOME}/jupyter-age/jupyter/:/root/.jupyterhub/ -v ${HOME}/jupyter-age/data/:/srv/jupyterhub/ -p 8081:8000 -it mpgagebioinformatics/jupyter-age:latest /bin/bash
jupyter lab --ip=0.0.0.0 --port=8000 --allow-root
```

A link of the type http://127.0.0.1:8000/?token=e8a687aa90fca358de6ce6b8a8ea802d11b257dd63a41eef will be shown to you. Replace the ip and port so that it looks like this - http://0.0.0.0:8081/?token=e8a687aa90fca358de6ce6b8a8ea802d11b257dd63a41eef and use this link to access jupyter lab.

All installed Python and R packages will me stored on your hosts `${HOME}/jupyter-age/jupyter/` while data that you might wish to use will need to be in `${HOME}/jupyter-age/data/`.
 
**Running the Jupyter enviroment over the terminal**

```
r2d2:~$ singularity exec /beegfs/common/singularity/jupyter.2.0.0.sif /bin/bash
```

If you are using our latest instance of JupyterHub - jupyterhub-test.age.mpg.de - please check the respective [README](https://github.com/mpg-age-bioinformatics/jupyterhub/tree/master/3.0.0).

--- 

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
docker pull alpine:latest
```
Than Tag your Image for our registry
```bash
docker tag alpine:latest hub.age.mpg.de/drosskopp/anyname:version
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

--- 

## Selfservice

For running your own `jupyter lab` and `rstudio-server` from the HPC you will need to 

```bash
export PATH=/beegfs/common/cluster_first_steps:${PATH}
```

A) and then, for `jupyter lab`,

```bash
cd ; srun -c 2 jupyter-age
```
 
for listing your running `jupyter` servers:

```
jupyter-age list
```

B) for `rstudio-server`,

```bash
cd ; srun -c 2 rstudio-age
```

For using VS Code over `ssh` you can do so using the Remote Development extension pack and following the instrucions [here](https://code.visualstudio.com/docs/remote/ssh).

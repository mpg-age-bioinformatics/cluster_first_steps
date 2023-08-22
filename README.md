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

If you would like to get access to the hpc cluster at the MPI-AGE please mail bioinformatics@age.mpg.de.

Once you have been given access you can login to one of the 2 head nodes with:

```bash
ssh -XY <username>@hpc.bioinformatics.studio
```

If the hpc node is not available, use:

```bash
ssh -XY <username>@hpc-login.bioinformatics.studio
```

--- 

## SLURM, Simple Linux Utility for Resource Management 

SLURM (Simple Linux Utility for Resource Management) is an open-source workload manager and job scheduler used primarily in high-performance computing (HPC) environments. It manages and schedules tasks across a cluster of computers, optimizing resource utilization and maximizing throughput.

### Basic SLURM Concepts

**Jobs**

A job is a unit of work submitted to SLURM for execution. It can consist of one or more tasks, where each task is a process or a thread running on a node.

**Partitions**

Partitions (also known as queues) are groups of nodes with similar characteristics, such as CPU type, memory, or GPU availability. Jobs can be submitted to  specific partitions based on the requirements. There are two partitions available in `hpc bioinformatics studio`: `cluster` and `dedicated`, where `cluster` is the default partition. Each node in `cluster` partition consists of 20 cores and 70GB RAM, where worker nodes in `dedicated` partition are with 32 cores and 960GB RAM.

**Nodes**

Nodes are individual computers in the cluster that execute jobs. Each node has its own set of resources, such as CPUs and memory.

**Resources**

SLURM manages and allocates resources for jobs based on user requirements. This includes CPU cores, memory, and other hardware resources.

### SLURM Commands

**`sinfo`: Cluster Information**

View partition information
```bash
sinfo 
``` 

Show information of nodes
```bash
sinfo -N
sinfo -N -O partitionname,nodehost,cpus,cpusload,freemem,memory
```

Show information about nodes with a specific state (e.g., idle, alloc, mix, etc.)
```bash
sinfo -t <node_state>
```

**`sbatch`: Submitting Jobs**

Submit jobs to SLURM
```bash
sbatch [options] script.sh
```
Where `script.sh` is the shell script containing the commands you want to execute.

Common options:

- `-p <partition>`: Specify the partition/queue for the job.
- `-n <tasks>`: Number of tasks in the job.
- `--cpus-per-task=<cores>`: Specify the number of CPU cores per task.
- `--mem=<memory>`: Request memory for the job.

Example with options
```bash
sbatch -p <partition> --cpus-per-task=<n cpus> --mem=<n>gb -t <hours>:<minutes>:<seconds> -o <stdout file> <script>
```

Submissions wihtout arguments specifications will result in `-p cluster` and a time limit of 2 weeks.

Feel free to use all partitions (ie. **cluster** and **dedicated** partition) for large job submissions.

When submitin jobs with `sbatch` you can also include SLURM parameters inside the script ie.:
```bash
#!/bin/bash
#SBATCH -p <partition> 
#SBATCH --cpus-per-task=<n cpus> 
#SBATCH --mem=<n>gb 
#SBATCH -t <hours>:<minutes>:<seconds> 
#SBATCH -o <stdout file> 

<code>
```
and then run the script with `sbatch <script>`.

Following is an example of managing large number of jobs to prevent overloading the cluster. It is strongly recommended to limit the number of simultaneously running jobs.
```bash
#!/bin/bash
cd ~/project/raw_data
for f in $(ls *.fastq);
   do  rm ~/project/slurm_logs/${f}.*.out

   # wait if the running jobs exceed the limit
   while [  `squeue –u username | wc –l` -gt "500" ];
      do echo "sleeping"; sleep 300
   done

   sbatch --cpus-per-task=18 --mem=15gb --time=5-24 \
   -p cluster -o ~/project/slurm_logs/${f}.%j.out ~/project/tmp/${f}.sh << EOF
   #!/bin/bash
   # necessary operations
   EOF

done
exit
```

Dependencies and Job Chains: e.g. submit a job3 after job1 and job2 are successfully ready
```bash
job1=$(sbatch --parsable <script1>)
job2=$(sbatch --parsable <script2>)
sbatch -d afterok:${job1}:${job2} <script3>
```

**`srun`: Launch Task and Interactive Session**

Start an interactive bash session
```bash
srun --pty bash
```

Attach to a running job and run a command
```bash
srun --jodib <job_id> --pty <command>
```

**`squeue`: Checking Queue Status**

Show the queue information
```bash
squeue
```

Queue infromation with option
```bash
squeue [options]
```

Common options:

- `-u <username>`: Show jobs for a specific user.
- `-p <partition>`: Show jobs in a specific partition.

**`scontrol`: Controlling Jobs**

Show detailed information about a job
```bash
scontrol show job <job_id>
```

Show information about a partition
```bash
scontrol show partition <parition_name>
```

Show information about a node
```bash
scontrol show node <node_name>
```

Hold a job
```bash
scontrol hold <job_id>
```

Release a job
```bash
scontrol release <job_id>
```

Change the partitions preference of a pending job
```bash
scontrol update job <job id> partition=<partition1>,<partition2>,<partition3>
```

Change the partition and reserved specific nodes
```bash
scontrol update job <job id> partition=<partition1>,<partition2>,<partition3> nodelist=<node list>
```

**`scancel`: Cancelling Jobs**

Cancel a job
```bash
scancel <job_id>
```

--- 

## Singularity

Singularity (also known as Apptainer) enables container images for HPC. In a nutshell, Singularity allows end-users to efficiently and safely run a docker image in an HPC system.

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
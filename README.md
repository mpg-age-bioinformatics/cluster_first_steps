## Table of Contents

[Getting Started](#getting-started)

[SLURM](#slurm-simple-linux-utility-for-resource-management)

[Modules](#environment-modules-project)

[Singularity](#singularity)

[Data](#data)

[Posit Bioinformatics Studio](#posit-bioinformatics-studio)

[Remote Visualization Services](#remote-visualization-services)

[Support](#support)

## Getting Started

In order to access the cluster, you will need to have a user account at the Max Planck Computing and Data Facility - [MPCDF Registration](https://selfservice.mpcdf.mpg.de/index.php?r=registration). If you already have an MPCDF account and would like to access our HPC please mail us at bioinformatics@age.mpg.de.  

**Login to the HPC User Node**

For security reasons, direct login to the HPC system is allowed only from within the MPG network.


From the MPG network (when over at the institute or over VPN):

```bash
ssh <username>@hpc.bioinformatics.studio
```

Where `<username>` is your MPCDF login.

Outside the MPG network:
```bash
ssh <username>@gate.mpcdf.mpg.de
```

then,
```bash
ssh <username>@hpc.bioinformatics.studio
```
--- 

## SLURM, Simple Linux Utility for Resource Management 

SLURM (Simple Linux Utility for Resource Management) is an open-source workload manager and job scheduler used primarily in high-performance computing (HPC) environments. It manages and schedules tasks across a cluster of computers, optimizing resource utilization and maximizing throughput.

### Basic SLURM Concepts

**Jobs**

A job is a unit of work submitted to SLURM for execution. It can consist of one or more tasks, where each task is a process or a thread running on a node.

**Partitions**

Partitions (also known as queues) are groups of nodes with similar characteristics, such as CPU type, memory, or GPU availability. Jobs can be submitted to  specific partitions based on the requirements. There are two partitions available in `hpc bioinformatics studio`: `cluster` and `dedicated`, where `cluster` is the default partition.

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
   while [  `squeue -u <username> | wc -l` -gt "500" ];
      do echo "sleeping"; sleep 300
   done

   sbatch --cpus-per-task=4 --mem=8gb --time=5-24 \
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
srun --jobid <job_id> --pty <command>
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

### Monitoring Resource Usage by Job

It is important to assign right amount of resources (e.g. number of CPUs:`--cpus-per-task`, memory:`--mem`) for a job.
Over assignments of resources occupies unnecessary space or computational power and it may prevent running new jobs or lead to higher waiting times for other users.

In order to have an idea about resource usage by a job, run `htop` command via a running job:
```
srun --jobid <job_id> --pty htop --user=$USER
```
From the outupt, `CPU%`, `MEM%` of the running processes/jobs will provide you an overall idea about the resource usage, which can be helpful for better assignment of resources. 

Also, you can get simple but useful job stats using `reportseff` command:
```
reportseff <job_id>
```

In order to get all the recent job stats run by your user:
```
reportseff -u $USER
```

---  

## Singularity

Singularity/Apptainer (also known as Apptainer) enables container images for HPC. In a nutshell, Singularity allows end-users to efficiently and safely run a docker image in an HPC system.

An introduction to docker and how to generate your own images can be found [here](https://github.com/mpg-age-bioinformatics/mpg-age-bioinformatics.github.io/blob/master/tutorials/reproducible_multilang_workflows_with_jupyter_on_docker.pdf). More information on how to build docker images and best practices for writing Dockerfiles can be found [here](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/) and [here](https://docs.docker.com/engine/reference/builder/), respectively.

Singularity/Apptainer is directly available on our HPC (no neeed to load any module).

Pull a docker image and convert to a Singularity image. The resulting Singularity image will contain the software and environment defined by the Docker image.
```bash
singularity pull bioinformatics_software.v4.0.2.sif  docker://index.docker.io/mpgagebioinformatics/bioinformatics_software:v4.0.2
```

Launch an interactive Bash shell within the context of the specified Singularity image
```bash
singularity exec bioinformatics_software.v4.0.2.sif /bin/bash
```

Detailed documentation for Apptainer is available [here](https://apptainer.org/user-docs/master/).

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
chmod +x test.sh
singularity exec bioinf.sif ./test.sh
```


> /modules/software/python/2.7.15/bin/python
> This is python
> /modules/software/rlang/3.5.1/bin/R
> [1] "This is R"

**Running a script over singularity on slurm:**

- example script: `test.slurm.sh`
```bash
#!/bin/bash
#SBATCH --cpus-per-task=18
#SBATCH --mem=15gb
#SBATCH --time=5-24 
#SBATCH -p cluster
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
chmod +x test.slurm.sh
sbatch test.slurm.sh
```
```
Submitted batch job 4684802
```
- check the output
```bash
cat test.singularity.out
> /modules/software/python/2.7.15/bin/python
> This is python
>
> /modules/software/rlang/3.5.1/bin/R
> [1] "This is R"
```


**Example for automation over a batch of jobs:**

- example script: `automation.slurm.singularity.sh`
```bash
#!/bin/bash
cd ~/project/raw_data			
for f in $(ls *.fastq); 
   do  rm ~/project/slurm_logs/${f}.*.out

   sbatch --cpus-per-task=18 --mem=15gb --time=5-24 \
   -p dedicated -o ~/project/slurm_logs/${f}.%j.out <<EOF
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

Our `mpgagebioinformatics/bioinformatics_software` make use of the modules system to load and unload required software.

The Environment Modules Project is a centralized software system. The modules system loads software (version of choice) and changes environment variables (eg. LD_LIBRARY_PATH).

```bash
# show available modules
module avail			

# show a description of the samtools module
module whatis samtools	

# show environment changes for samtools
module show samtools

# load samtools
module load samtools		

# list all loaded modules
module list	  

# unload the samtools module
module unload samtools	

# unload all loaded modules
module purge  			
```

--- 
 
## Data

Data can be accessed from our `hpc.bioinformatics.studio` as well as from `raven.mpcdf.mpg.de` : 

```
cd /nexus/posix0/MAGE-flaski/service/hpc/
```

There you will find a `home/<username>` folder to store your data and a `group/<group name>` to share data within your group.

From `raven.mpcdf.mpg.de`  you will be able to transfer your data to `/raven/ptmp` (also efemeral) eg.:

```
rsync -rtvh /nexus/posix0/MAGE-flaski/service/hpc/group/<group>/<folder> /raven/ptmp/<user>/
```
or to the archive file system:

```
rsync -rtvh /nexus/posix0/MAGE-flaski/service/hpc/group/<group>/<folder> /r/<username first letter>/<user>/
```

For more information on the `/raven/ptmp` and archive `/r` please consult MPCDF's [documentation](https://docs.mpcdf.mpg.de/doc/computing/raven-user-guide.html#file-systems).

Data stored on the cluster is not backed up. Files will be deleted parmanently after being unused for 3 months. You are responsible for the backup of your data into a different file system.

The clients needs to be able to use `scp`, which means secure copy, pointing that your files are crypted during the copy process. We would recommend using filezilla. This Gui is available most known Operating systems, like Windows, Linux or OS-X (if you have a MAC). Alternatively you can use `rsync` or modern file transfer tools that make use of the same file transfer protocols.

```bash
# on the server side
scp </path/to/file> <username>@<address>:~/path/to/file
```

```bash
# on your client side
scp <username>@<address>:</path/to/file> ~/path/to/file
```

---

## Posit Bioinformatics Studio

Posit is a data science developer platform that provides access to multiple development environment including Rstudio, Jupyter Notebook, JupyterLab and VS Code. With Posit Bioinformatics Studio, you can run multiple-concurrent sessions as well as use different versions of R and Python.  

It is available at [https://docker.bioinformatics.studio/posit](https://docker.bioinformatics.studio/posit) and can be accessed through the institute networks (e.g. internal wifi, lan, vpn, MPCDF gateways). In order to access the service, you need to have a user account at the Max Planck Computing and Data Facility - [MPCDF Registration](https://selfservice.mpcdf.mpg.de/index.php?r=registration). If you already have an MPCDF account and would like to use Posit Bioinformatics Studio, please mail us at bioinformatics@age.mpg.de.
### Login & Home

Login to the platform is possible with your MPCDF user credentials.

Your home directory would be in `/nexus/posix0/MAGE-flaski/service/posit/<user>`. However, when starting a new VS Code or Jupyter session terminal, you may find the current location as the primary home of `/home/<user>`. A simple `cd` command would take you to the home directory in nexus space.

Additionally, `hpc.bioinformatics.studio` home or group directory can also be accessed from the platform. To learn more about managing data, please look into the [Data](#data) section.

### Installing Python Packages as User

From the command line (eg. JupyterLab terminal or VScode terminal):
```
$ source /python.rc 

Available python versions:

3.10.8  3.11.0  3.8.10  3.9.5  jupyter

use 'source /python.rc <version>' to load the respective environment.

$ source /python.rc 3.10.8
$ pip3 install pandas --user
$ pip3 show pandas
Name: pandas
Version: 1.5.1
Summary: Powerful data structures for data analysis, time series, and statistics
Home-page: https://pandas.pydata.org
Author: The Pandas Development Team
Author-email: pandas-dev@python.org
License: BSD-3-Clause
Location: /nexus/posix0/MAGE-flaski/service/posit/home/jboucas/.jupyter/python/3.10/lib/python3.10/site-packages
Requires: numpy, python-dateutil, pytz
Required-by: AGEpy, formulaic, lifelines, seaborn, statsmodels
```

### R update.packages and versions

Users should run `update.packages()` upon first R login.

To change R version and set appropriate env variables from terminal, `/r.rc` can be used.

Check the available R versions
```
source /r.rc
```

Set R version
```
source /r.rc <version>
```

---

## Remote Visualization Services

For further remote visualization services please consult MPCDF's [documentation](https://docs.mpcdf.mpg.de/doc/visualization/index.html) and previous training [slides](https://datashare.mpcdf.mpg.de/s/iYB7xA8FN4igkxW).

In order run visual tools such as `posit/rstudio` or `jupyterlab` on `hpc.bioinformatics.studio` (possibly with custom parameters/resources) via a slurm job and access it from your local browser, please look into [visual_tools](/visual_tools).

Also, it is possible to run rstudio in your local device using your preferred [rocker rstudio images](https://rocker-project.org/images/).

---

## Support

For any query and support, please do not hesitate to get in touch through: bioinformatics@age.mpg.de

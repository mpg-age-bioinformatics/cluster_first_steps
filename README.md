## General

If you would like to get access to the local cluster at the MPI-AGE
please mail bioinformatics@age.mpg.de.

Once you have been given access you can login to one of the 2 head nodes with:

```bash
ssh -XY UName@cluster.age.mpg.de
```

or

```bash
ssh -XY UName@cluster2.age.mpg.de
```

The first time you login you should download the following `.bash_profile` and source it:

```bash
cd ~
wget https://raw.githubusercontent.com/mpg-age-bioinformatics/cluster_first_steps/master/.bash_profile
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

# start and interactive bash session
srun --pty bash

# submit a job
sbatch -p <partition> --cpus-per-task=<n cpus> --mem=<n>gb -t <hours>:<minutes>:<seconds> -o <stdout file> <script>  

# submit a job3 after job1 and job2 are successfully ready
job1=$(sbatch <script1> 2>&1 | awk '{print $(4)}')
job2=$(sbatch <script2> 2>&1 | awk '{print $(4)}')
sbatch -d afterok:${job1}:${job2} <script3>

# cancel a job
scancel <job id>

# cancel all jobs for user
scancel -u <user name>
```

Submissions wihtout arguments specifications will result in `-p blade --cpus-per-task=2` and a time limit of 2 weeks.

For large job submissions please use the **blade** partition. For large jobs submission over large periods (eg. more than a week) please use the **long** partition. 

Feel free to use the **himem** and **hugemem** partitions for large job submissions as well provided you can easely make these two partitions free on request of other users (eg. if you are submiting short jobs this should be easely achievable by using *sview* to modify the target partitions of your jobs).

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

# loads SAMtools
module load SAMtools		

# lists all loaded modules
module list	  

# unload the SAMtools module
module unload SAMtools	

# unload all loaded modules
module purge  			
```

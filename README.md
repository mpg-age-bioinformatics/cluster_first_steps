## General

If you would like to get access to the local cluster at the MPI-AGE
please mail bioinformatics@age.mpg.de.

Once you have been given access you can login to one of the 2 head nodes with:

```bash
ssh -XY UName@cluster
```

or

```bash
ssh -XY UName@cluster2
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

Feel free to use all partitions (ie. also the **himem** and **hugemem** partitions) for large job submissions as well provided you can easely make these two partitions free on request of other users (eg. if you are submiting short jobs this should be easely achievable by using `sview` to modify the target partitions of your jobs).

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
scp UName@cluster:</path/to/file> ~/Desktop
```

transfer data to the server

```bash
# on the client side
scp </path/to/file> UName@cluster:~/
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
In filezilla you have to open the site Manager and you have to make an entry like this one:

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
sshfs JDoe@cluster:/beegfs/group_XX ~/cluster_mount
```

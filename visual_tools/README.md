## Visual Tools

Run different tools from `hpc` using singularity containers and access these from the local browser.

### Step 1: Run Script
Run the corresponding script as a slurm job from `hpc node`.

Scripts are stored in path `/usr/share/vt/`
```
sbatch [options] /usr/share/vt/<script>
```
For example, to launch `posit-jupyter` with default parameters:
```
sbatch /usr/share/vt/posit-jupyter
```
Can add different job parameters based on you requirements:
```
sbatch --partition=<value> --cpus-per-task=<value> --mem=<value> --output=<value> /usr/share/vt/posit-jupyter
```
In order to use a different image:
```
sbatch --export=ALL,IMAGE=<image_path> /usr/share/vt/posit-jupyter
```

### Step 2: Get Instructions
From the job output, get the instructions:
```
cat <job_output_file>
```
To show the output file location as well as the job information:
```
scontrol show job <job_id>
```

### Step 3: Follow Instructions
Just follow the fetched instructions to launch the required tool. Followings are the common procedures:

- Do SSH port forwarding from your local computer to `hpc node`: open a local terminal and run the provided command (keep open)
- Access the tool from browser with the provided URL (also with credentials if necessary)
- When done using, exit the port forwarding and cancel the job with `scancel -f <job_id>`

## posit-jupyter
It is recommended to use `posit-jupyter` script as it has more features in one place with the following properties:

- Encrypted https connection
- Multiple versions of R
- Multiple versions of Python
- Option to create R, Python, text or Markdown files

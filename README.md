# DIDA-Seq

## Organization

This snakemake workflow includes two workflows, which are linked together. The first takes 1 or more "run" files (R1 and R2), which is then demultiplexed into multiple files using a metadata file which links each sample ID to it's unique barcode. Once the files have been demultiplexed, these individual files are processed in parallel through a sequence of processing steps.
* The first workflow is executed by the Snakefile `demultiplex_Snakefile`, and defines it's sample IDs by parsing through the metadata file provided, which includes the one-to-one mapping of sample ID to barcode. 
* The second workflow defines the first as it's "sub-workflow" and requires that it is completed prior to launching any of the downstream processing steps. This workflow is defined by `Snakefile` and defines the demultiplexing as it's "sub-workflow"

## Software requirements

To launch this workflow properly, you must:
* Have miniconda3 installed. If this is not installed, you can install with the following commands.

```
$ cd ~
$ wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
$ bash Miniconda3-latest-Linux-x86_64.sh
```

* Install snakemake through `conda` into your base environment.

```
$ conda install -c bioconda -c conda-forge snakemake
```

## Setup

Clone this repository into your preferred location.

```
$ git clone https://github.com/ohsu-cedar-comp-hub/DIDA.git
$ cd DIDA
```

Once in the directory `DIDA`, you must upload the necessary files for demultiplexing to be run properly. Please upload a *tab-delimited text file* following this format:

|           |                  |
|-----------|------------------|
| sample1   | gtcaNNNNgtcaNNNN |
| sample2   | aagtNNNNaagtNNNN |
| sample3   | aaccNNNNaaccNNNN |
|   ...     |        ...       |

**Important** to note is that snakemake defines the samples to run in parallel by parsing through this file, so please *only include the sample IDs & barcodes which were run.*

Once this file is uploaded, you can write the absolute path to it under the `barcodes` header in the file `omic_config.yaml`. The `omic_config.yaml` file is also where you can alter the following variables which may change depending on your run:
1. `barcodes` - Metadata file which links sample ID to barcode
2. `ref_genome` - Reference genome fasta file
3. `num_pcr` - Number of processors 
4. `gd_cutoff`
5. `gd_Ncutoff`

Once you have uploaded your metadata and edited the `omic_config.yaml` to your liking, please symbolically link / copy your raw sequencing files to the directory `samples/raw` within your working directory.

```
$ ln -s /path/to/data/* samples/raw
```

OR

```
$ cp /path/to/data/* samples/raw
```

## Launch workflow

To test that your workflow is set up correctly, you can do a "dry-run" of your snakemake workflow, which will create a Directed Acyclic Graph (DAG) of every job that will be launched in the workflow. If there are any syntactical errors, they will be reported here.

```
$ snakemake -np --verbose
```

If the dry-run looks good, then you can launch the workflow with this command:

```
$ sbatch submit_snakemake.sh
```

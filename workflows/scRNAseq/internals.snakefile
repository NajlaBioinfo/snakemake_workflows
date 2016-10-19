import glob
import os
import subprocess


### Functions ##################################################################

def get_sample_names(infiles):
    """
    Get sample names without file extensions
    """
    s = []
    for x in infiles:
        x = os.path.basename(x).replace(ext,"")
        try:
            x = x.replace(reads[0],"").replace(reads[1],"")
        except:
            pass
        s.append(x)
    return(sorted(list(set(s))))


def is_paired(infiles):
    """
    Check for paired-end input files
    """
    paired = False
    infiles_dic = {}
    for infile in infiles:
        fname = os.path.basename(infile).replace(ext, "")
        m = re.match("^(.+)("+reads[0]+"|"+reads[1]+")$", fname)
        if m:
            ##print(m.group())
            bname = m.group(1)
            ##print(bname)
            if bname not in infiles_dic:
                infiles_dic[bname] = [infile]
            else:
                infiles_dic[bname].append(infile)
    if infiles_dic and max([len(x) for x in infiles_dic.values()]) == 2:
        paired = True
    # TODO: raise exception if single-end and paired-end files are mixed
    return(paired)



### Variable defaults ##########################################################

try:
    indir = config["indir"]
except:
    indir = os.getcwd()

try:
    outdir = config["outdir"]
except:
    outdir = os.getcwd()

## paired-end read name extension
try:
    reads = config["reads"]
except:
    reads = ["_R1", "_R2"]

## FASTQ file extension
try:
    ext = config["ext"]
except:
    ext = ".fastq.gz"

## downsampling - number of reads
try:
    downsample = int(config["downsample"])
except:
    downsample = None

try:
    genome = config["genome"]
except:
    genome = None

try:
    mate_orientation = config["mate_orientation"]
except:
    mate_orientation = "--fr"

# IMPORTANT: When using snakemake with argument --config key=True, the
# string "True" is assigned to variable "key". Assigning a boolean value
# does not seem to be possible. Therefore, --config key=False will also
# return the boolean value True as bool("False") gives True.
# In contrast, within a configuration file config.yaml, assigment of boolean
# values is possible.
try:
    if config["trim"]:
        trim = True
        fastq_dir = "FASTQ_TrimGalore"
    else:
        trim = False
        fastq_dir = "FASTQ"
except:
    trim = False
    fastq_dir = "FASTQ"

try:
    trim_galore_opts = config["trim_galore_opts"]
except:
    trim_galore_opts = "--stringency 2"


try:
    mapq = int(config["mapq"])
except:
    mapq = 0

try:
    bw_binsize = int(config["bw_binsize"])
except:
    bw_binsize = 10



### Initialization #############################################################

infiles = sorted(glob.glob(os.path.join(indir, '*'+ext)))
samples = get_sample_names(infiles)

paired = is_paired(infiles)

if not paired:
    reads = [""]
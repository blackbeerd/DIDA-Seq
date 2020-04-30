# This is a Snakefile to work on the demultiplexed files

__author__ = "Breeshey Roskams-Hieter"
__email__ = "roskamsh@ohsu.edu"

import datetime
import sys
import os
import pandas as pd
import json

timestamp = ('{:%Y-%m-%d_%H:%M:%S}'.format(datetime.datetime.now()))

configfile:"omic_config.yaml" 

subworkflow demultiplex:
    snakefile:
        "demultiplex_Snakefile"
    configfile:
        "omic_config.yaml"

md = open(config['barcodes'], "r")
lines = md.readlines()

SAMPLES = []
for x in lines:
    SAMPLES.append(x.split('\t')[0])
md.close()


with open('cluster.json') as json_file:
    json_dict = json.load(json_file)

rule_dirs = list(json_dict.keys())
rule_dirs.pop(rule_dirs.index('__default__'))

for rule in rule_dirs:
    if not os.path.exists(os.path.join(os.getcwd(),'logs',rule)):
        log_out = os.path.join(os.getcwd(), 'logs', rule)
        os.makedirs(log_out)
        print(log_out)

def message(mes):
    sys.stderr.write("|--- " + mes + "\n")

for sample in SAMPLES:
    message("Sample " + sample + " will be processed")

rule all:
    input:
        expand("samples/bwa/{sample}.pe.sam", sample = SAMPLES)

include: "rules/DIDA.smk"


rule format_migec:
    input:
        fwd = "samples/raw/{run}.r1.fq",
        rev = "samples/raw/{run}.r2.fq"
    output:
        fwd = "samples/migec/{run}_migec.r1.fq",
        rev = "samples/migec/{run}_migec.r2.fq"
    shell:
        """scripts/format_migec.sh -f {input.fwd} -r {input.rev} -F {output.fwd} -R {output.rev}"""

rule migec:
    input:
        fwd = "samples/migec/{run}_migec.r1.fq",
        rev = "samples/migec/{run}_migec.r2.fq"
    output:
        "samples/demultiplexed/{run}/checkout.log.txt"
    params:
        migec = "executables/migec-1.2.9.jar",
        barcodes = "data/snakemake_pipeline_NovaSeq_8bp_barcodes.txt" 
    shell:
        """java -Xmx24G -jar {params.migec} Checkout -ou -r 0:0 {params.barcodes} {input.fwd} {input.rev} ./samples/demultiplexed/{wildcards.run}"""

rule add_smi:
    input:
        expand("samples/demultiplexed/{run}/checkout.log.txt", run = RUNS)
    output:
        expand("samples/demultiplexed/{sample}_R1.fastq.smi", sample = SAMPLES),
        expand("samples/demultiplexed/{sample}_R2.fastq.smi", sample = SAMPLES)
    shell:
        "scripts/add_smi.sh"

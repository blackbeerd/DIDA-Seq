rule bwa:
    input:
        fwd = demultiplex("samples/demultiplexed/{sample}_R1.fastq.smi"),
        rev = demultiplex("samples/demultiplexed/{sample}_R2.fastq.smi")
    output:
        "samples/bwa/{sample}.pe.sam"
    params:
        ref_genome = config['ref_genome']
    conda:
        "../envs/DIDA.yaml"
    shell:
        """bwa mem {params.ref_genome} -t 8 -Ma {input.fwd} {input.rev} > {output}"""

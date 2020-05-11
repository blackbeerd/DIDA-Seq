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

rule sort:
    input:
        "samples/bwa/{sample}.pe.sam"
    output:
        "samples/bwa/{sample}.pe.sort.bam"
    conda:
        "../envs/DIDA.yaml"
    shell:
        """samtools view -Sbu {input} | samtools sort - samples/bwa/{wildcards.sample}.pe.sort"""

rule add_readgroups:
    input:
        "samples/bwa/{sample}.pe.sort.bam"
    output:
        "samples/bwa/{sample}.pe.sort.readgroups.bam"
    shell:
        """java -Xmx25g -jar executables/AddOrReplaceReadGroups.jar INPUT={input} OUTPUT={output} RGLB=UW RGPL=Illumina RGPU=ATATAT RGSM=default"""

rule index:
    input:
        "samples/bwa/{sample}.pe.sort.readgroups.bam"
    output:
        "samples/bwa/{sample}.pe.sort.readgroups.bam.bai"
    conda:
        "../envs/DIDA.yaml"
    shell:
        """samtools index {input}"""

rule consensus:
    input:
        raw = demultiplex("samples/demultiplexed/{sample}_R1.fastq.smi"),
        bam = "samples/bwa/{sample}.pe.sort.readgroups.bam",
        bai = "samples/bwa/{sample}.pe.sort.readgroups.bam.bai"
    output:
        main = "samples/consensus/{sample}.sscs.{num_pcr}pcr.bam",
        r1 = "samples/consensus/{sample}.sscs.{num_pcr}pcr.r1.fq",
        r2 = "samples/consensus/{sample}.sscs.{num_pcr}pcr.r2.fq"
    params:
        num_pcr = config["num_pcr"],
        gd_cutoff = config["gd_cutoff"],
        gd_Ncutoff = config["gd_Ncutoff"]
    conda:
        "../envs/conmaker.yaml"
    shell:
        """scripts/consensus_maker.sh -s executables/bp_consensusmaker_v3.2.py -i {input.bam} -t samples/consensus/{wildcards.sample}.pe.sort.readgroups.tagcounts -o {output.main} -m {params.num_pcr} -c {params.gd_cutoff} -N {params.gd_Ncutoff} -r {input.raw}"""

rule no_num:
    input:
        r1 = "samples/consensus/{sample}.sscs.{num_pcr}pcr.r1.fq",
        r2 = "samples/consensus/{sample}.sscs.{num_pcr}pcr.r2.fq"
    output:
        r1 = "samples/consensus/{sample}.sscs.{num_pcr}pcr.r1.no_num.fq",
        r2 = "samples/consensus/{sample}.sscs.{num_pcr}pcr.r2.no_num.fq"
    shell:
        """awk  'BEGIN {{ OFS = "\t" }} ; {{ sub(/:1/, "", $1) }}1' {input.r1} | awk  'BEGIN {{ OFS = "\t" }} ; {{ sub(/:2/, "", $1) }}1' > {output.r1}
        awk  'BEGIN {{ OFS = "\t" }} ; {{ sub(/:1/, "", $1) }}1' {input.r2} | awk  'BEGIN {{ OFS = "\t" }} ; {{ sub(/:2/, "", $1) }}1' > {output.r2}"""

rule align_sscs:
    input:
        r1 = "samples/consensus/{sample}.sscs.{num_pcr}pcr.r1.no_num.fq",
        r2 = "samples/consensus/{sample}.sscs.{num_pcr}pcr.r2.no_num.fq"
    output:
        "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sam"
    params:
        ref_genome = config['ref_genome']
    conda:
        "../envs/DIDA.yaml"
    shell:
        """bwa mem {params.ref_genome} -t 8 -Ma {input.r1} {input.r2} > {output}"""

rule sort_sscs:
    input:
        "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sam"
    output:
        "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.bam"
    conda:
        "../envs/DIDA.yaml"
    shell:
        """samtools view -bu {input} | samtools sort - samples/sscs/{wildcards.sample}.sscs.{wildcards.num_pcr}pcr.aln.sort"""

rule index_sscs:
    input:
        "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.bam"
    output:
        "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.bam.bai"
    conda:
        "../envs/DIDA.yaml"
    shell:
        """samtools index {input}"""

rule add_readgroups_sscs:
    input:
        bam = "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.bam",
        bai = "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.bam.bai"
    output:
        "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.readgroups.bam"
    shell:
        """java -Xmx25g -jar executables/AddOrReplaceReadGroups.jar INPUT={input.bam} OUTPUT={output} RGLB=UW RGPL=Illumina RGPU=ATATAT RGSM=default"""

rule index_readgroups:
    input:
        "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.readgroups.bam"
    output:
        "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.readgroups.bam.bai"
    conda:
        "../envs/DIDA.yaml"
    shell:
        """samtools index {input}"""

rule clipreads:
    input:
        raw = demultiplex("samples/demultiplexed/{sample}_R1.fastq.smi"),
        bam = "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.readgroups.bam"
    output:
        "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.trimmed.bam"
    conda:
        "../envs/gatk.yaml"
    shell:
        """scripts/clip_reads.sh -i {input.bam} -o {output} -r {input.raw}"""

rule clip_overlap:
    input:
        "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.trimmed.bam"
    output:
        "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.complete.bam"
    shell:
        """executables/bam clipOverlap --in {input} --stats --out {output}"""

rule index_complete:
    input:
        "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.complete.bam"
    output:
        "samples/sscs/{sample}.sscs.{num_pcr}pcr.aln.sort.complete.bam.bai"
    conda:
        "../envs/DIDA.yaml"
    shell:
        """samtools index {input}"""


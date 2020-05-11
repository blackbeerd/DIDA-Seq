rule reheader:
    input:
        bam = expand("samples/sscs/{{sample}}.sscs.{num_pcr}pcr.aln.sort.complete.bam", num_pcr = num_pcr),
        bai = expand("samples/sscs/{{sample}}.sscs.{num_pcr}pcr.aln.sort.complete.bam.bai", num_pcr = num_pcr)
    output:
        "samples/mutect2/{sample}.reheadered.bam"
    conda:
        "../envs/DIDA.yaml"
    shell:
        """samtools view -H {input.bam} | sed 's/default/{wildcards.sample}/' | samtools reheader - {input.bam} > {output}"""

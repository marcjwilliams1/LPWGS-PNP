import glob
def _merge_files(wildcards):
    return glob.glob("tempbams/" + wildcards.sample + "*.bam")
def _split_file(wildcards):
    wildcards.sample.split("_")[0]



#def _merge_files(wildcards):
#    return glob.glob("tempbams/" + wildcards + "_S[0-9]+\_L[0-9]+\.bam")

rule picard_merge_bam:
    input:
        _merge_files
    output:
        "mergedbams/{sample}.bam"
    threads: 1
    run:
        #output = {output}
        #print({output})
        inputstr = " ".join(["INPUT={}".format(x) for x in input])
        print(inputstr)
        shell("module load java")
        shell("echo hello")
        shell("echo {{inputstr}}; echo {{output}}".format(inputstr=inputstr, output = {output}))
        shell("java -jar -Xmx4G $PICARD MergeSamFiles {{inputstr}} OUTPUT={{output}}".format(inputstr=inputstr,output = {output}))


rule indexdedupbam:
    input:
        bam="mergedbams/{sample}.bam",
    output:
        bam="bams/{sample}.bam",
        metrics="QC/dedupmetrics/{sample}.dedup.txt"
    threads: 1
    shell:
        """
        module load java
        java -jar -Xmx4G $PICARD MarkDuplicates \
        INPUT={input.bam} \
        OUTPUT={output.bam} \
        METRICS_FILE={output.metrics} \
        CREATE_INDEX=true \
        REMOVE_DUPLICATES=true
        """

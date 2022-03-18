#!/bin/bash

# Batch process Picard ADDorReplaceGroups

INPUTDIR=<input>
base=<folder for AddorReplace Groups or Project> 
outdir=$base/output
shdir=$base/sh_scripts

mkdir -p $base
mkdir -p $outdir
mkdir -p $shdir

cd $INPUTDIR
ls *.bam > $shdir/bams

cd $shdir
sed 's/....$//' bams > bam
rm bams
mv bam bams

module load picard/2.10.9

for bam in $(cat bams); do
 cat << EOF > $shdir/${bam}.sh
#!/bin/bash
#
#$ -cwd

module load picard/2.10.9

 java -Xmx2g -jar picard.jar AddOrReplaceReadGroups \
       I=$INPUTDIR/${bam}.bam \
       O=$outdir/${bam}.AddorReplaceRG.bam \
       RGLB=30XWGS \
       RGPL=ILLUMINA \
       RGSM=$bam
 
EOF

done

cd $shdir

ls *.sh > files
for file in $(cat files);do
sbatch -c 1 -t 24:00:00 --mem 3G $file

done

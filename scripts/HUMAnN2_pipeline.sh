#!/usr/bin/env bash
#$ -o ./log/
#$ -e ./log/


#STEPS
# run the humann2 
# renormalize to copies per million and relative abundance 
# map to KO and EC terms
# remove the intermediate files

#specify paths 

WORKING_DIR=/klaster/scratch/mmaranga/functional_analysis/diabimmune_data/
READ_DIR=${WORKING_DIR}/combined_data 
OUTPUT_DIR=${WORKING_DIR}/uniref90_diabimmune_humman2_analysis 
MAPPING_FILES=/home/mmaranga/utility_mapping/

cd $WORKING_DIR

# running humann2

for file in $READ_DIR/*fastq.gz
	do 
	humann2 -i ${file} -o $OUTPUT_DIR
done

# Merge gene family and abundance files 

humann2_join_tables -i $OUTPUT_DIR -o $OUTPUT_DIR/merged_genefamilies.tsv --file_name genefamilies

humann2_join_tables -i $OUTPUT_DIR -o $OUTPUT_DIR/merged_pathabundance.tsv --file_name pathabundance

humann2_join_tables -i $OUTPUT_DIR -o $OUTPUT_DIR/merged_pathcoverage.tsv --file_name pathcoverage

# normalization
#normalizing to copies per million
humann2_renorm_table -i $OUTPUT_DIR/merged_genefamilies.tsv -o $OUTPUT_DIR/normalized_genefamilies_cpm.tsv --units cpm
humann2_renorm_table -i $OUTPUT_DIR/merged_pathabundance.tsv -o $OUTPUT_DIR/normalized_pathabundance_cpm.tsv --units cpm

# normalizing to relative abundance
humann2_renorm_table -i $OUTPUT_DIR/merged_genefamilies.tsv -o  $OUTPUT_DIR/normalized_genefamilies_relab.tsv --units relab
humann2_renorm_table -i $OUTPUT_DIR/merged_pathabundance.tsv -o $OUTPUT_DIR/normalized_pathabundance_relab.tsv --units relab

# map to KO  
humann2_regroup_table -i $OUTPUT_DIR/normalized_genefamilies_cpm.tsv -o $OUTPUT_DIR/normalized_genefamilies_cpm_KO.tsv -c $MAPPING_FILES/map_ko_uniref90.txt.gz 

# map genefamilies abundance to Enzyme Commission (EC) terms
humann2_regroup_table -i $OUTPUT_DIR/normalized_genefamilies_cpm.tsv -o $OUTPUT_DIR/normalized_genefamilies_cpm_EC.tsv -c $MAPPING_FILES/map_level4ec_uniref90.txt.gz

# remove the intermediate files
rm -rf $OUTPUT_DIR/*_humann2_temp

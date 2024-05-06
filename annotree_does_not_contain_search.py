### Imports of necessary libraries
import pandas as pd
import numpy as np
import os
import sys
import glob

##### Gets the gtdb taxonomy formatted for downstream parsing ################
def process_taxonomy_file(file):
    # Read taxonomy file and rename columns
    df = pd.read_csv(file, sep='\t', header=None).rename(columns={0: 'gtdbid', 1: 'full_tax'})
    # Splits the taxonomy classifications into columns. Keeps the original output as full_tax column
    df[['domain', 'phylum', 'class', 'order', 'family', 'genus', 'species']] = df['full_tax'].str.split(';', expand=True)
    return df

##### Have the archaea and bacteria taxonomy tsv files in a dir
tax_dir = glob.glob('gtdbr214_tax/*')

gtdb_tax_db_comb = pd.concat([process_taxonomy_file(file) for file in tax_dir])

print(gtdb_tax_db_comb)

##### Compares two annotree output files for finding genomes that contain gene1 but not gene2 since Annotree does not provide this search option
def get_unique_ids(input_files):
    def cat_list_csvs(csv):
        return pd.read_csv(csv)[['gtdbId']]
    unique_ids = pd.concat([cat_list_csvs(csv) for csv in input_files]).drop_duplicates()
    return unique_ids

#####  Specify input file paths for gene1 and gene2
input_annotree_hits_gene1 = [
    'gene1_arch_annotree_hits.csv',
    'gene1_arch_annotree_hits.csv'
]
input_annotree_hits_gene2 = [
    'gene2_arch_annotree_hits.csv',
    'gene2_bact_annotree_hits.csv'
]

##### Get unique GTDB IDs for gene1 and gene2 searches
gene1_ids = get_unique_ids(input_annotree_hits_gene1)
gene2_ids = get_unique_ids(input_annotree_hits_gene2)

##### Get GTDB IDs present in gene1 search but not in gene2 search
gene1_no_gene2_IDs = gene1_ids.merge(gene2_ids, how='outer', indicator=True)[(lambda x: x['_merge'] == 'left_only')].drop('_merge', axis=1)

print(gene1_no_gene2_IDs)


##### Combines the gtdbIDs present in gene1 and not gene2 with gtdb taxonomy #######
gene1_no_gene2_tax = pd.DataFrame(gtdb_tax_db_comb[gtdb_tax_db_comb['gtdbid'].isin(gene1_no_gene2_IDs['gtdbId'])])

##### Gets the number of genomes hits per phylum in search and adds the column to the new df
phylum_counts = pd.DataFrame({'phylum': gene1_no_gene2_tax['phylum'].value_counts().index,
                              'number_of_genome_hits': gene1_no_gene2_tax['phylum'].value_counts().values})

##### Cleans the names of phylum
phylum_counts['phylum'] = phylum_counts['phylum'].map(lambda x: x.lstrip('p__'))


##### Adds in the total phylum tallys from Annotree for downstream analysis
annotree_phylum_count_bact = pd.read_excel('annotree_phy_counts_r214.xlsx', 
                                           sheet_name='bacteria_phyla')
annotree_phylum_count_arch = pd.read_excel('annotree_phy_counts_r214.xlsx',
                                           sheet_name='archaea_phyla')

phylum_counts_annotree = pd.concat([annotree_phylum_count_bact, annotree_phylum_count_arch], ignore_index=True, sort=False)

##### Calculates some stats to match Annotree outputs on single gene searches
##### merges dfs on phylum
gene1_no_gene2_ip= pd.merge(phylum_counts, phylum_counts_annotree, on='phylum')
##### sums all hits for this search
total_hits = gene1_no_gene2_ip['number_of_genome_hits'].sum()
##### adds stat proportion_of_hits_per_search  by dividing the number_of_genome_hits by the total hits per phyla
gene1_no_gene2_ip['proportion_of_hits_per_search'] = gene1_no_gene2_ip['number_of_genome_hits'] / total_hits
##### adds stat percent_of_genomes_in_clade by dividing the number_of_genome_hits by the annotree count of phyla
gene1_no_gene2_ip['percent_of_genomes_in_clade'] = (gene1_no_gene2_ip['number_of_genome_hits'] / gene1_no_gene2_ip['annotree_count'])
##### adds a column to note which taxonomy level is being worked with
gene1_no_gene2_ip['tax_class']='phylum_name'
##### renames column for downstream parsing
gene1_no_gene2_ip=gene1_no_gene2_ip.rename(columns={'phylum': 'tax_name'})
##### renames column for downstream parsing
gene1_no_gene2_ip['input_csv_file']='gene1_no_gene2'
##### Add '_arch' to 'gene' where 'bacteria' is 'archaea'
gene1_no_gene2_ip.loc[gene1_no_gene2_ip['domain'] == 'archaea', 'input_csv_file'] += '_arch'
gene1_no_gene2_ip.loc[gene1_no_gene2_ip['domain'] == 'bacteria', 'input_csv_file'] += '_bact'
gene1_no_gene2_ip = gene1_no_gene2_ip.drop(columns=['domain'])
gene1_no_gene2_ip=gene1_no_gene2_ip.rename(columns={'annotree_count': 'number_of_genomes_in_clade'})

print(gene1_no_gene2_ip)

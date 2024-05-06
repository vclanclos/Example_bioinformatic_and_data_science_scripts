# About
## These scripts are intended to display a proficiency for python and R in the context of bioinformatic usage. 

1. **annotree_does_not_contain_search.py** was created to be used with Annotree (http://20.151.176.175/annotree/app/). 
Annotree is a great tool that allows a user to comb through an annotated GTDB (https://gtdb.ecogenomic.org/). Currently, the user can only search genomes for the PRESENCE of genes common to a genome, but can not search for the presence of one gene with the absence of another. This first-draft script allows for reconstruction of an Annotree search that mimics a "does not contain" search.

   Inputs needed:
     *  GTDB database taxonomy file for bacteria and archaea
     *  Two outputs from Annotree for the gene1 and gene2 search
     *  Table of Annotree phyla counts with sheets for bacteria and archaea separated

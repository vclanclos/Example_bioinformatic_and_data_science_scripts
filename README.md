# About
## These scripts are intended to display a proficiency for python and R in the context of bioinformatics and data science. 

1. **annotree_does_not_contain_search.py** was created to be used with Annotree (http://20.151.176.175/annotree/app/). 
Annotree is a great tool that allows a user to comb through an annotated GTDB (https://gtdb.ecogenomic.org/). Currently, the user can only search genomes for the PRESENCE of genes common to a genome, but can not search for the presence of one gene with the absence of another. This first-draft script allows for reconstruction of an Annotree search that mimics a "does not contain" search.

   Inputs needed:
     *  GTDB database taxonomy file for bacteria and archaea
     *  Two outputs from Annotree for the gene1 and gene2 search
     *  Table of Annotree phyla counts with sheets for bacteria and archaea separated

2. **metagenomic_recruitment_plot.R** was published as part of https://www.nature.com/articles/s41396-023-01376-2 and https://github.com/thrash-lab/Lanclos_et_al_2022_figures. 

   Inputs needed:
     *  RPKM table generated through metagenomic recruitment. See rrap (https://journals.asm.org/doi/10.1128/mra.00644-22) for a straightforward description of metagenomic recruitment or use any in-house pipeline for this.
     *  Metadata table for metagenome samples

3. **debt_interest_calculator_with_slider.py** was a pet-project to better visualize how monthly payment amounts change total interest, monthly interest, and time to debt payoff. This produces an interactive plot that allows a shift of monthly payment amounts to project debt payoff and interest paid over 5 years.
 
   Inputs needed:
     *  Loan balance
     *  Loan annual interest rate

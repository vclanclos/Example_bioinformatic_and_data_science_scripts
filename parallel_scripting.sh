#### Example of how to run a parallel job ####
# Problem: I want to run >4000 genomic files through a program. In this case it is GenomeSpot. Submitting one script will take too long, so 
# I want to blast off a bunch of smaller scripts

#Input: basenames.txt file with basenames of genomes
split -l 50 basenames.txt
#Output: many files with 50 lines each. These are labeled xaa, xab, etc

#Create a template script to input the split files through the commands to run:
#template_script.sh

#!/bin/bash --login
#SBATCH --partition=XX
#SBATCH --account=XX
#SBATCH --qos=XX
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=2:00:00

while IFS= read -r line; do
    fna_file="PATHTOFILES/${line}.fna"
    faa_file="PATHTOFILES/${line}.fna.faa"
    output_file="PATHTOFILES/${line}.gs"

    python -m genome_spot.genome_spot --models models --contigs "$fna_file" --proteins "$faa_file" --output "$output_file"
done <"$1"

#Loop through the splitfiles to create scripts for each splitfile
for file in x*; do
    cp template_script.sh "script_$file.sh"
    sed -i "s/\$1/$file/g" "script_$file.sh"
done

#Check if scripts are executable and change permissions if needed with your preferred chmod. EX:
chmod -R 755 ./ 

#Submit each script
for script in script_*.sh; do
    sbatch "$script"
done


#!/software/pathogen/external/apps/usr/local/bin/Rscript

# Take the output files from the pan genome pipeline and create nice plots.

mydata = read.table("number_of_new_genes.tab")
boxplot(mydata, data=mydata, main="Number of new genes",
         xlab="Number of genomes", ylab="Number of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)

mydata = read.table("number_of_conserved_genes.tab")
boxplot(mydata, data=mydata, main="Number of conserved genes",
          xlab="Number of genomes", ylab="Number of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)
 
mydata = read.table("number_of_genes_in_pan_genome.tab")
boxplot(mydata, data=mydata, main="Number of genes in the pan-genome",
          xlab="Number of genomes", ylab="Number of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)

mydata = read.table("number_of_unique_genes.tab")
boxplot(mydata, data=mydata, main="Number of unique genes",
         xlab="Number of genomes", ylab="Number of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)



#!/usr/bin/env Rscript
# ABSTRACT: Create R plots
# PODNAME: create_plots.R
# Take the output files from the pan genome pipeline and create nice plots.
library(ggplot2)


mydata = read.table("number_of_new_genes.Rtab")
boxplot(mydata, data=mydata, main="Number of new genes",
         xlab="No. of genomes", ylab="No. of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)

mydata = read.table("number_of_conserved_genes.Rtab")
boxplot(mydata, data=mydata, main="Number of conserved genes",
          xlab="No. of genomes", ylab="No. of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)
 
mydata = read.table("number_of_genes_in_pan_genome.Rtab")
boxplot(mydata, data=mydata, main="No. of genes in the pan-genome",
          xlab="No. of genomes", ylab="No. of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)

mydata = read.table("number_of_unique_genes.Rtab")
boxplot(mydata, data=mydata, main="Number of unique genes",
         xlab="No. of genomes", ylab="No. of genes",varwidth=TRUE, ylim=c(0,max(mydata)), outline=FALSE)

mydata = read.table("blast_identity_frequency.Rtab")
plot(mydata,main="Number of blastp hits with different percentage identity",  xlab="Blast percentage identity", ylab="No. blast results")


library(ggplot2)
conserved = colMeans(read.table("number_of_conserved_genes.Rtab"))
total = colMeans(read.table("number_of_genes_in_pan_genome.Rtab"))

genes = data.frame( genes_to_genomes = c(conserved,total),
                    genomes = c(c(1:length(conserved)),c(1:length(conserved))),
                    Key = c(rep("Conserved genes",length(conserved)), rep("Total genes",length(total))) )
                    
ggplot(data = genes, aes(x = genomes, y = genes_to_genomes, group = Key, linetype=Key)) +geom_line()+
theme_classic() +
ylim(c(1,max(total)))+
xlim(c(1,length(total)))+
xlab("No. of genomes") +
ylab("No. of genes")+ theme_bw(base_size = 16) +  theme(legend.justification=c(0,1),legend.position=c(0,1))+
ggsave(filename="conserved_vs_total_genes.png", scale=1)

######################

unique_genes = colMeans(read.table("number_of_unique_genes.Rtab"))
new_genes = colMeans(read.table("number_of_new_genes.Rtab"))

genes = data.frame( genes_to_genomes = c(unique_genes,new_genes),
                    genomes = c(c(1:length(unique_genes)),c(1:length(unique_genes))),
                    Key = c(rep("Unique genes",length(unique_genes)), rep("New genes",length(new_genes))) )
                    
ggplot(data = genes, aes(x = genomes, y = genes_to_genomes, group = Key, linetype=Key)) +geom_line()+
theme_classic() +
ylim(c(1,max(unique_genes)))+
xlim(c(1,length(unique_genes)))+
xlab("No. of genomes") +
ylab("No. of genes")+ theme_bw(base_size = 16) +  theme(legend.justification=c(1,1),legend.position=c(1,1))+
ggsave(filename="unique_vs_new_genes.png", scale=1)

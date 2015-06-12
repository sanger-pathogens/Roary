#Roary plots
Marco Galardini (marco@ebi.ac.uk) has prepared an ipython notebook which can take in a tree (newick) and the gene presence and absence spreadsheet, and generate some nice plots.

The dependancies are:
- python (2 or 3)
- Biopython
- numpy
- pandas
- matplotlib
- seaborn

Usage:
```
python roary_plots.py my_tree.tre gene_presence_absence.csv
```

The images it produces are:
* A pan genome frequency plot
* A presence and absence matrix against a tree
* A piechart of the pan genome, breaking down the core, soft core, shell and cloud.

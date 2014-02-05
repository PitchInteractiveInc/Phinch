# Phinch

![VizGallery](https://github.com/shujianbu/phinch/blob/master/viz_gallery.png?raw=true)

## About 

[Phinch](http://phinch.org/) is an open-source framework for visualizing biological data, funded by a grant from the [Alfred P. Sloan foundation](http://www.sloan.org/). This project represents an interdisciplinary collaboration between [Pitch Interactive](http://www.pitchinteractive.com/beta/index.php), a data visualization studio in Berkeley, CA, and biological researchers at [UC Davis](http://www.ucdavis.edu/). Whether it's genes, proteins, or microbial species, Phinch provides an interactive visualization tool that allows users to explore and manipulate large biological datasets. 

[Phinch](http://phinch.org/) is optimized for use in the Chrome browser. It currently supports downstream analyses of .biom files ([Biological Observation Matrix](http://biom-format.org/), a JSON-formatted file type typically used to represent marker gene OTUs or metagenomic data). All sample metadata and taxonomy/ontology information MUST be embedded in the .biom file before being uploaded. 

## Prepare Data

Phinch supports both "sparse" and "dense" BIOM formats (although sparse .biom files are highly recommended, since the file size is much smaller). In [QIIME](http://qiime.org/), users can prepare the .biom file by executing the following commands:
```Python
make_otu_table.py -i final_otu_map_mc2.txt -o otu_table_mc2_w_tax.biom -t rep_set_tax_assignments.txt
```

Second, add your sample metadata to your .biom file. Where your input file (-i) is your OTU Map (defining clusters of raw sequences reads), taxonomy file (-t) contains the taxonomy or gene ontology strings that correspond to each OTU, and mapping file (-m) is a tab-delimited file containing sample metadata ([ instructions](http://qiime.org/documentation/file_formats.html#metadata-mapping-files)).
```Python
add_metadata.py -i otu_table_mc2_w_tax.biom -o otu_table_mc2_w_tax_and_metadata.biom -m sample_metadata_mapping_file.txt
```

## Libraries 

## Setup 

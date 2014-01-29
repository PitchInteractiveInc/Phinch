# Phinch

![VizGallery](https://github.com/shujianbu/phinch/blob/master/viz_gallery.png?raw=true)

### About 

[Phinch](http://phinch.org/) is an open-source framework for visualizing biological data, funded by a grant from the [Alfred P. Sloan foundation](http://www.sloan.org/). This project represents an interdisciplinary collaboration between [Pitch Interactive](http://www.pitchinteractive.com/beta/index.php), a data visualization studio in Berkeley, CA, and biological researchers at [UC Davis](http://www.ucdavis.edu/). </br></br>
            
Whether it's genes, proteins, or microbial species, Phinch provides an interactive visualization tool that allows users to explore and manipulate large biological datasets. Computer algorithms face significant difficulty in identifying simple data patterns; writing algorithms to tease out complex, subtle relationships (the type that exist in biological systems) is almost impossible. However, the human eye is adept at spotting visual patterns, able to quickly notice trends and outliers. It is this philosophy especially when presented with intuitive, well-designed software tools and user interfaces.</br></br>
            
The sheer volume of data produced from high-throughput sequencing technologies will require fundamentally different approaches and new paradigms for effective data analysis.</br></br>

Scientific visualization represents an innovative method towards tackling the current bottleneck in bioinformatics; in addition to giving researchers a unique approach for exploring large datasets, it stands to empower biologists with the ability to conduct powerful analyses without requiring a deep level of computational knowledge. 

### Instructions

[Phinch](http://phinch.org/) is optimized for use in the Chrome browser.

This visualization framework aims to address current bottlenecks in the analysis of large sequence datasets (rRNA amplicons, metagenomes), helping researchers analyze high-throughput datasets more efficiently. Phich takes advantage of standard outputs from computational pipelines in order to bridge the gap between biological software (e.g. QIIME) and existing data visualization capabilities (harnessing the scalability of WebGL and HTML5 in a browser-based tool). 

[Phinch](http://phinch.org/) currently supports downstream analyses of .biom files ([Biological Observation Matrix](http://biom-format.org/), a JSON-formatted file type typically used to represent marker gene OTUs or metagenomic data). All sample metadata and taxonomy/ontology information MUST be embedded in the .biom file before being uploaded into [Phinch](http://phinch.org/).

In QIIME (version 1.7 or later), users can prepare the .biom file by executing the following commands:

```Python
make_otu_table.py -i final_otu_map_mc2.txt -o otu_table_mc2_w_tax.biom -t rep_set_tax_assignments.txt
```

Where your input file (-i) is your OTU Map (defining clusters of raw sequences reads), and taxonomy file (-t) contains the taxonomy or gene ontology strings that correspond to each OTU.
Second, add your sample metadata to your .biom file:

```Python
add_metadata.py -i otu_table_mc2_w_tax.biom -o otu_table_mc2_w_tax_and_metadata.biom -m sample_metadata_mapping_file.txt
```

Where your input file (-i) is your .biom file from the previous step, and your mapping file (-m) is a tab-delimited file containing sample metadata ([formatted according to these QIIME instructions](http://qiime.org/documentation/file_formats.html#metadata-mapping-files)).

After these two steps, you're ready to upload.

If you want to visualize biological data currently formatted as a tab-delimited text file (e.g. the style of OTU tables produced by older versions of QIIME), [please refer to this documentation for conversion instructions](https://github.com/biom-format/biom-format/blob/df81277857a553e7e5c9679924e09861d8a5f61f/doc/documentation/biom_conversion.rst). Phinch supports both "sparse" and "dense" BIOM formats (although sparse .biom files are highly recommended, since the file size is much smaller). 

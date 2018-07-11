# ContentDM-Mappings
This repository contains resources used in conjunction with the Islandora ContentDM to MODS Staging module: crosswalk maps, alternate file maps, and processes to perform interventions on MODS files prepared by the ContentDM-to-MODS crosswalk prior to ingest into Islandora.

Manifest:
* `/mods-maps` contains MODS files mapping the ContentDM-to-MODS crosswalk performed as a part of IRL's migration to Islandora. This folder has `mods-all-nodes.xml`, a sample template containing what should be most of the elements a UIOWA ContentDM need mapped.
* `/alt-file-maps` contains the .csv files for swapping in locally stored images for the ContentDM records. For a collection not mapping in alternate files the `alt-file-map-null.csv` is to be used.
* `/mods-processes`
* `/exports` contains exports of ContentDM collections being migrated.
* `/reports` contains outputs of reports assisting development of crosswalks, e.g. reports of all distinct elements contained in a ContentDM Custom XML export as an aid to mapping.

## MODS Maps
| Collection | Map |
| ---------- | -- |
| Iowa City Town and Campus Scenes | mods-map-ictcs.xml |
| John P. Vander Maas Railroadiana | mods-map-rr.xml |
| Nile Kinnick Collection | kinnick-mods-crosswalk.xml |

## Alternate File Maps
| Collection | Map |
| ---------- | -- |
| NA | NA |

## MODS Processes

### Data Updates

| xsl / perl | Functions |
| ---------- | ---------- |
| `uiowa-mods-updates.xsl` | Fixes values of typeOfResource; removes some empty elements; parses /mods/name[count(namePart) > 1] into multiple /mods/name; breaks out ';' delimited /mods/subject/topic values; replaces /mods/titleInfo/title of compound children with the value of the parent title; conflates latitude and longitude to a single /mods/subject/cartographics/coordinates element |
| `uiowa-mods-updates.pl` | Sample perl script showing how to use a scripting language to execute processes over the MODS files. Any other scripting language, e.g. python, will work just fine. This particular one has a depency on the Java version of the Saxonica PE XSL processor. You may use any xsl processor you like, the xsl transformations here use no proprietary extensions. |
| `split-mods-files.xsl` | For handling very large files it is sometimes required to split output files into smaller batches. Set the `$object-per-file` param to the number of objects per file. |

### Structural Updates
The default behavior of the ContentDM to MODS module is to process hierarchical compounds from ContentDM into a mirroring structure of collections, subcollections, and child objects. This may or may not suit the desired outcomes depending on the type of assets being catalogued in a given collection. The processes below give options for restructuring the default output into other types of objects or structures. Options include:
- alter the default back to compounds
- alter the default into books
- selectively apply either of the above updates based on criteria, e.g.
  - A string contained within a title.
  - The presence of a processing instruction. (When programmatic criteria can't be used this is a handy way to insert indications of which objects should be altered.)

The last option gives you a way to process collections where the global options may not work well, i.e. the content types are not consistent and may present better in different models, such as the case where you may want to retain collections and subcollections for photographs, but convert scrapbooks to books.

#### Other Notes
- The term "final level" is used here to refer to refer to the last node in a hierarchy of collections, i.e. if a collection A contains subcollection B which contains subcollection C, when there are no further nested collections C is the final level.
- Compounds coming from ContentDM may have only one child, which is cumbersome as the compound is redundant. Another option offered below is a process for removing that layer of hierarchy.

| xsl / perl | Functions |
| ---------- | ---------- |
| `cdm-mods-final-level-to-compounds.xsl` | Alters standard output by changing any (sub)collection containing only image objects (no subcollections) into a compound object. This can be modified to be less selective, i.e. create compounds with arbitrary non-collection cModel types. `cdm-mods-updates-single-children.xsl` should always be run (next) over the output of this transform. Requires passing in $islandora-namespace parameter. |
| `cdm-mods-final-level-to-books.xsl` | Alters standard output by changing any (sub)collection containing only image objects (no subcollections) into a book, and its children into pages. Requires passing in $islandora-namespace parameter. |
| 'cdm-mods-final-level-to-books-select.xsl' | Performs the same as `cdm-mods-final-level-to-books.xsl`, except it demonstrates how to selectively alter final level collections into books. |
| `cdm-mods-subcollections-to-compounds.xsl` | Alters standard output by changing any (sub)collection structure into a compound. This should be followed by `cdm-mods-updates-single-children.xsl`. |
| 'cdm-mods-select-compounds-to-books.xsl' | Once the default output structure of collections has been reverted to compounds, this transform demonstrates how to selectively alter compounds into books. See the comments it contains. This is meant to be run following `cdm-mods-final-level-to-compounds.xsl`, and should be followed by 'cdm-mods-updates-single-children.xsl' |
| `cdm-mods-updates-single-children.xsl` | When a compound object has only one child, this removes the parent object, moves the parent metadata to the child, and assigns the child to the collection the parent was a member of. In a processing chain, or sequence of transforms, this should always be run last. |

### Sample Sequences
To affect desired outcomes processing chains - sequences of transformations or other interventions - need to be set up. Here are a few examples:

#### Retain Compound Structures Globally
1. cdm-mods-subcollections-to-compounds.xsl
2. cdm-mods-updates-single-children.xsl

Note: This is rarely if ever as effective as the retaining compound structures at the final level.

#### Retain Compound Structures at Final Level 
1. cdm-mods-final-level-to-compounds.xsl
2. cdm-mods-updates-single-children.xsl

#### Retain Compounds, Turn Selected Final Level Collections into Books
1. cdm-mods-final-level-to-compounds.xsl
2. cdm-mods-select-compounds-to-books.xsl
3. cdm-mods-updates-single-children.xsl

## Test Files
It's useful to have a small set of test files that can be used to iteratively develop postprocesses. Being small they ingest quickly and don't take up a lot of spac. /test-files/contentdm-exports' contains a subset of the Nile Kinnick Collection in standard and custom xml export forms. They contain compound objects and so can be used to develop, test, and check out postprocessing options. Use them with the MODS crosswalk template for that collection.

Typical iterative process for testing:
1. Submit a request to the Islandora ContentDM to MODS staging module
2. Download the MODS xml
3. Perform postprocessing
4. Replace the MODS xml file associated with the request with the postprocessed output
5. Generate and ingest the batch associated with the request

You can reiterate the process using the same request by:
- deleting the batch
- Repeating steps 2 - 5 above
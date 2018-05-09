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
| xsl / perl | Functions |
| ---------- | ---------- |
| `uiowa-mods-updates.xsl` | Fixes values of typeOfResource; removes some empty elements; parses /mods/name[count(namePart) > 1] into multiple /mods/name; breaks out ';' delimited /mods/subject/topic values; replaces /mods/titleInfo/title of compound children with the value of the parent title; conflates latitude and longitude to a single /mods/subject/cartographics/coordinates element |
| `uiowa-mods-updates-single-children.xsl` | Removes compound object when has only one child. |
| `uiowa-mods-updates.pl` | Sample perl script showing how to use a scripting language to execute processes over the MODS files. Any other scripting language, e.g. python, will work just fine. This particular one has a depency on the Java version of the Saxonica PE XSL processor. You may use any xsl process you like, the xsl transformations here have no dependencies on any proprietary extensions. |
| `cdm-mods-subcollections-to-compounds.xsl` | Alters standard crosswalk handling of hierarchical compounds - into collections/subcollections - back to nested compounds. UNTESTED. |

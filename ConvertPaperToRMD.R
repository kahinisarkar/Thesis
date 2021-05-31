# this script will convert a docx to an rmarkdown file. For citations to be carried over do the following prior to conversion:
# 1) use Zotero as your citation manager
# 2) install the BetterBibTex addon
# 3) change the hidden option citeprocNoteCitekey to "yes"
# 4) in Zotero prefrences>BetterBibtex. Change citekey to the following: 
# [auth:lower:clean:fold:condense][shorttitle3_3:clean:fold:condense][year:clean:fold:condense]
# 5) use this csl https://raw.githubusercontent.com/retorquere/zotero-better-bibtex/master/better-bibtex-citekeys.csl
# for citation style

# To get rMarkdown working make sure to do the following:
# install.packages(c('tinytex', 'rmarkdown'))
# tinytex::install_tinytex()
# #after restarting RStudio, confirm that you have LaTeX with
# tinytex:::is_tinytex() 

# After conversion:
# 1) export a .bib corresponding to the paper (https://rintze.zelle.me/ref-extractor/ can be used)
# 2) refer to example_conversion_with_cits.rmd for configuring the rmd.
# 3) The YAML header for the .rmd is as follows
# 4) '[@' and ']' will be escaped with '\' This script attempts to find 
# and remove these escapes on brackets matching this pattern
# 5) This script attempts to fix a bug with the "'" symbol which may be inappropriately escaped.
# If brackets are used in the doc, the .csl can be changed to include a "code" to aid find and replace.

# ---
# title: "Your Title here"
# output:
#   pdf_document:
#     latex_engine: xelatex
# bibliography: "RiBi_Paper.bib"
# ---

package_list = c("rmarkdown", "devtools", "stringr", "readr", "readtext", "renv")

package.check <- lapply(
  package_list,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)

library(rmarkdown)
library(devtools)

examplefile=""
file_name = strsplit(examplefile, ".docx")[[1]]
pandoc_convert(examplefile, to="markdown", output = paste0(file_name, "_temp.rmd"), options = "-s")

library(stringr)
library(readr)
library(readtext)

fix_inline_citations = function(text_to_convert) {
 text_fix_last =  str_replace_all(text_to_convert, "(\\\\\\[\\\\@[a-zA-Z0-9]*[(;[:blank:]\n\\-\\\\@)[a-zA-Z0-9:\n\\-[:blank:]]]*)(\\\\\\])", "\\1]")
 text_fix_middle = str_replace_all(text_fix_last, ";\\\\@|;[:blank:]\\\\@|;\n\\\\@", ";@")
 text_fix_first = str_replace_all(text_fix_middle, "(\\\\\\[\\\\@)", "[@")
 return(text_fix_first)
}

fix_prime = function(text_to_convert) {
  text_fix = str_replace_all(text_to_convert, pattern = "(?<!\\\\)(')", replacement = "\\\\'")
  return(text_fix)
}

converted_doc = readtext(paste0(file_name, "_temp.rmd"))
doc_cit_fix = fix_inline_citations(converted_doc)
doc_prime_cit_fix = fix_prime(doc_cit_fix)

write_lines(doc_prime_cit_fix, paste0(file_name, ".rmd"))

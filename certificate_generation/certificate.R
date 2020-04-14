################################################################################
# Certificate Creation for RLB

# (c) Thomas Ludwig; 03/2020
################################################################################

# packages for analysis

library(tidyverse) # data manipulation
library(rmarkdown) # render reports
library(stringr) # string manipulation
library(here) # path handling

# ------------------------------------------------------------------------------

set_here() # Need this later especially when rendering R markdown

# create (or read) data by loading names of participants
attendees <- data.frame(Name = c("Thomas Ludwig", "Simon Rossi",
                                 "Aaron Müssner", "Peter Schmid"),
                        Date = "01.01.2020",
                        stringsAsFactors = FALSE,
                        check.names = FALSE)


# create output names
attendees$filePDF <- paste0("Output/Bestätigung_",
                         gsub(" ", "_", attendees$Name), 
                         ".pdf")


# function for creating the certificates
certificate <- function(template, attendeeName, outPDF, knitDir, date){
  cat("\n Starting:", outPDF, "\n")
  
  # Create a temporary Rmd file with the attendee and event information.  
  templateCert <- read_file(template)
  tmpRmd <- templateCert %>%
    str_replace("<<ATTENDEE_NAME>>", attendeeName) %>%
    str_replace("<<DATE>>", date)
  
  # The knitdir has to be defined for the rmarkdown::render to work.
  RmdFile <- tempfile(tmpdir = knitDir, fileext = ".Rmd")
  write_file(tmpRmd, RmdFile)
  
  # Creating the certificates using R markdown.
  rmarkdown::render(RmdFile, output_file = here(outPDF), quiet = TRUE,
                    encoding = "UTF-8")
  
  # Temporary .Rmd file can be deleted.
  file.remove(RmdFile)
  cat("\n Finished:", outPDF, "\n")
}

# ------------------------------------------------------------------------------

# run function and produce reports

for (i in seq_len(nrow(attendees))) {
  with(attendees,
       certificate(template = here("doc_test.txt"),
                   Name[i], filePDF[i], here(), Date[i])
  )
}

# ------------------------------------------------------------------------------

# Source and basic idea taken from:
# http://www.dsup.org/blog/creating-certificates-of-attendance-using-r/

################################################################################
################################################################################
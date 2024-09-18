# mapping between SEACAR & IMaRS provider names:
# names in      SEACAR     |  IMaRS
value_map <- c(
  # ??? = 21FLWQA
  "AOML_WQ_3" = "AOML", 
  "BBAP_WQ_5026" = "BBAP", 
  "BBWW_WQ_4057" = "BBWW",  # TODO: load new zip fild from box
  # ??? = "BROWARD", 
  "DEP_ECA_WQ - 5033" = "DEP",
  # ??? = "DERM",
  "MIAMI_BEACH_WQ_4058" = "Miami Beach",  # TODO: map this to merged "Miami Beach*"
  # ??? = "Miami Beach  Outfalls",
  # ??? = "Miami Beach Re-Sample",
  # ??? = "Palm Beach",
  "SERC_FKNMS_WQ_297" = "FIU",
  "SERC_WQ_509" = "FIU"
)

if (!requireNamespace("librarian", quietly = TRUE)) {
  install.packages("librarian")
}
librarian::shelf(
  glue,
  here,
  tidyverse
)

# function to get the IMaRS data for given SEACAR provider name
getIMaRSData <- function(seacar_provider_name){
  imars_name <- value_map[seacar_provider_name]
  
  # Load IMaRS-processed data & align to SEACAR columns
  imars_data <- read_csv(here(
    "../dep-wq-data-report/data/df_cleaned_02.csv"
  )) %>%
  filter(Source == imars_name) %>%
  mutate(  # mapping between column names
    ParameterName = Parameter,
    OriginalLatitude = Latitude,
    OriginalLongitude = Longitude,
    ProgramLocationID = Site,
    ResultValue = verbatimValue,
    SampleDate = glue(
      "{Year}-{sprintf('%02d', Month)}-{sprintf('%02d', Day)}"
    )  
  )
}

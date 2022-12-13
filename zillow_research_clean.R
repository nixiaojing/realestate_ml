### read and clean zillow research data
setwd("~/Desktop/GU/ANLY501/portfolio/data")

invt_sfr <- read.csv(file = 'Metro_invt_fs_uc_sfr_month.csv')
summary(invt_sfr)

invt_sfrcondo <- read.csv(file = 'Metro_invt_fs_uc_sfrcondo_month.csv')
summary(invt_sfrcondo)
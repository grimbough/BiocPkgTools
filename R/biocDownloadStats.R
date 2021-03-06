utils::globalVariables(c(".data", "biocViewsVocab"))

#' Get Bioconductor download statistics
#'
#' @details Note that Bioconductor package download
#' stats are not version-specific.
#'
#' @importFrom dplyr mutate %>%
#' @importFrom utils read.table
#' @importFrom tibble as_tibble
#'
#' @return A \code{data.frame} of download statistics for
#' all Bioconductor packages, in tidy format
#'
#' @examples
#' biocDownloadStats()
#'
#' @export
biocDownloadStats = function() {
  tmp = read.table('https://bioconductor.org/packages/stats/bioc/bioc_pkg_stats.tab',
                   sep="\t", header = TRUE, stringsAsFactors = FALSE)
  tmp$repo = 'Software'
  tmp2 = read.table('https://bioconductor.org/packages/stats/data-annotation/annotation_pkg_stats.tab',
                    sep="\t", header = TRUE, stringsAsFactors = FALSE)
  tmp2$repo = 'AnnotationData'
  tmp3 = read.table('https://bioconductor.org/packages/stats/data-experiment/experiment_pkg_stats.tab',
                    sep="\t", header = TRUE, stringsAsFactors = FALSE)
  tmp3$repo = 'ExperimentData'
  tmp = rbind(tmp,tmp2,tmp3)
  tmp = as_tibble(tmp) %>%
    dplyr::mutate(Date = as.Date(paste(.data$Year, .data$Month, '01'),
                                 '%Y %b %d'))
  class(tmp) = c('bioc_downloads', class(tmp))
  tmp
}

#' When did a package enter Bioconductor?
#'
#' This function uses the biocDownloadStats
#' data to *approximate* when a package entered
#' Bioconductor. Note that the download stats
#' go back only to 2009.
#'
#' @importFrom dplyr filter group_by top_n collect
#'
#' @param download_stats a data.frame from \code{\link{biocDownloadStats}}
#'
#' @examples
#'
#' dls <- biocDownloadStats()
#' tail(firstInBioc(dls))
#'
#' @export
firstInBioc = function(download_stats) {
  download_stats %>%
    dplyr::filter(.data$Month!='all') %>%
    dplyr::group_by(.data$Package) %>%
    # thanks: https://stackoverflow.com/questions/43832434/arrange-within-a-group-with-dplyr
    dplyr::top_n(1, dplyr::desc(.data$Date)) %>%
    dplyr::collect()
}

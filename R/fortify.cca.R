##' @title Fortify a \code{"cca"} object.
##'
##' @description
##' Fortifies an object of class \code{"cca"} to produce a
##' data frame of the selected axis scores in long format, suitable for
##' plotting with \code{\link[ggplot2]{ggplot}}.
##'
##' @details
##' TODO
##'
##' @param model an object of class \code{"cca"}, the result of a call to
##' \code{\link[vegan]{cca}}, \code{\link[vegan]{rda}}, or
##' \code{\link[vegan]{capscale}}.
##' @param data currently ignored.
##' @param display numeric; the scores to extract in the fortified object.
##' @param ... additional arguments passed to \code{\link[vegan]{scores.cca}}.
##' @return A data frame in long format containing the ordination scores.
##' The first two components are the axis scores.
##' @author Gavin L. Simpson
##'
##' @export
##'
##' @importFrom ggplot2 fortify
##' @importFrom vegan scores
##'
##' @examples
##' data(dune)
##' data(dune.env)
##'
##' sol <- cca(dune ~ A1 + Management, data = dune.env)
##' head(fortify(sol))
`fortify.cca` <- function(model, data,
                          display = c("sp", "wa", "lc", "bp", "cn"), ...) {
    scrLen <- function(x) {
        obs <- nrow(x)
        if(is.null(obs))
            obs <- 0
        obs
    }
    scrs <- scores(model, display = display, ...)
    ## handle case of only 1 set of scores
    if (length(display) == 1L) {
        scrs <- list(scrs)
        nam <- switch(display,
                      sp = "species",
                      species = "species",
                      wa = "sites",
                      sites = "sites",
                      lc = "constraints",
                      bp = "biplot",
                      cn = "centroids",
                      stop("Unknown value for 'display'"))
        names(scrs) <- nam
    }
    rnam <- lapply(scrs, rownames)
    take <- !sapply(rnam, is.null)
    rnam <- unlist(rnam[take], use.names = FALSE)
    scrs <- scrs[take]
    fdf <- do.call(rbind, scrs)
    rownames(fdf) <- NULL
    fdf <- data.frame(fdf)
    lens <- sapply(scrs, scrLen)
    fdf$Score <- factor(rep(names(lens), times = lens))
    fdf$Label <- rnam
    attr(fdf, "dimlabels") <- names(fdf)[1:2]
    names(fdf)[1:2] <- paste0("Dim", 1:2)
    fdf
}

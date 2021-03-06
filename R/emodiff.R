#' Calculate a suite of six emotion differentiation measures
#'
#' Given a dataframe of emotion data over time, a list of emotion variables in that dataset, and an ID variable,
#' calculates momentary emotional differentiation, classic emotion differentiation, L2 emotion differentiation, and
#' their inverses
#'
#' @return the input data.frame with 6 emotion differentiation variables appended
#'
#' @param dat a data.frame object with moment-level observations
#' @param emotions A character vector of all relevant emotion variables in dat
#' @param ... Grouping variable(s). Usually this will just be a person ID. Occasionally, you might have a wave ID and
#' a person ID, if you want to calculate scores for each individual within each wave.
#' @param allow_neg_icc Defaults to FALSE, which sets all emotion differentiation measures to NA if the ICCC for an
#' individual is negative. Recommended.
#' @param fisher_transform_icc Defaults to TRUE, which fisher-transforms c_ED and c_nonED (the ICC). Recommended.
#'
#' @examples
#' calculate_ed(dat = emo_ex, emotions = c("happy","relaxed","cheerful"), id)

calculate_ed <- function(dat, emotions, ..., allow_neg_icc = FALSE, fisher_transform_icc = TRUE) {

  center <- function(x){
    x - mean(x, na.rm = TRUE)
  }

  dat$row_id <- 1:nrow(dat)

  c_dat <- dat %>% group_by(...) %>% mutate(across(emotions, center))

  # Calculate person-level metrics

  person_dat <- c_dat %>% group_by(...) %>% group_split( .keep = TRUE) %>% lapply(., function(x)
    # Keep the ID vars
    cbind(x %>% select(row_id, ...),

          # Calculate emotional variance
          m_emo_var = sum(diag(var(x[, emotions]))),
          # Calculate classic (non) ED
          c_nonED = psych::ICC(x[emotions], missing = TRUE, lmer = F)$results[6, 2]

    )) %>%
    do.call('rbind', .)

  c_dat <- left_join(c_dat, person_dat)

  c_dat$momentary_squared_sum <- c_dat[emotions] %>% apply(., 1, function(x) (mean(x, na.rm = TRUE)*length(emotions))^2)

  c_dat$m_nonED <- c_dat$momentary_squared_sum/c_dat$m_emo_var
  c_dat$m_ED <- c_dat$momentary_squared_sum/c_dat$m_emo_var*-1


  if (fisher_transform_icc) {
    # We can safely transform before we flip to calculate c_ED or doing filtering, because fisher transform is
    # symmetrical around 0 and retains 0s.
    c_dat$c_nonED <- psych::fisherz(c_dat$c_nonED)
  }

  c_dat$c_ED <- c_dat$c_nonED*-1

  c_dat <- c_dat %>% group_by(...) %>% mutate(L2_nonED = sum(m_ED, na.rm = TRUE)/(n()-1))

  c_dat$L2_ED <- c_dat$L2_nonED*-1

  if (!allow_neg_icc) {
    # Set all measures of emotion differentiation to NA if the c_ED is negative
    c_dat <- c_dat %>% mutate(across(c('m_nonED', 'm_ED', 'c_nonED', 'c_ED', 'L2_nonED', 'L2_ED'),
                                     function(x) ifelse(c_nonED < 0, NA, x)))
  }


  out <- left_join(dat, select(c_dat, row_id, m_nonED, m_ED, c_nonED, c_ED, L2_nonED, L2_ED)) %>% select(-row_id)

  return(out)
}

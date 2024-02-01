# package for parallel computing
library(parallel)
# for missing value imputation
library(imputeTS)


### EMOS ####
# function for estimating EMOS with rolling training period
emos <- function(data, # data
                 obs_col, # observation column 
                 mean_col, # ensemble mean forecast column
                 sd_col, # ensemble standard deviation column
                 log_sd = TRUE, # if ensemble standard deviation should be log-transformed (TRUE)
                 location, # location/station id
                 ffd, # first forecast day
                 lfd, # last forecast day
                 l, # length of rolling training window
                 n_ahead, # integer corresponding to the forecast ahead time
                 cores = 1 # number of cores for parallel computing
                 ){
  
  # calculate forecast days
  fds <- seq(as.Date(ffd), as.Date(lfd), by = "days")
  
  train_data <- mclapply(1:length(fds), function(k) {
    init_date <- fds[k] - 1
    tmp <- tail(data[data$id == location & data$date <= init_date, c(obs_col, mean_col, sd_col)], n = l)
    tmp[, 1] <- c(tmp[1:(l-n_ahead), 1], rep(NA, n_ahead))
    tmp[, 1] <- imputeTS::na_ma(tmp[, 1])
    tmp
  }, mc.cores = cores)  
  
  # CRPS optimization function
  optim_fun <- function(pars, obs, m, s) {
    
    mu <- pars[1] + pars[2]*m
    sigma <- exp(pars[3] + pars[4]*s)
    
    z <- (obs - mu)/sigma
    crps <- sigma * (z * (2 * pnorm(z) - 1) + 2 * dnorm(z) - 1/sqrt(pi))
    sum(crps)
    
  }
  
  # estimate parameters for each forecast day k{
  out <- mclapply(1:length(train_data), function(k) { 
    
    # get data for day k
    obs <- train_data[[k]][, 1]
    m <- train_data[[k]][, 2]
    s <- train_data[[k]][, 3]
    
    # log-trafo for sd
    if (log_sd) {
      s <- log(s)
    }
    
    # get starting values for optimization
    pars <- c(coef(lm(obs ~ m)),
              0, 1)
    
    # try optimization with BFGS
    try_est <- try(expr = {
      
      # start optimization 
      result <- optim(par = pars, 
                      fn = optim_fun,
                      obs = obs, 
                      m = m,
                      s = s,
                      method = "BFGS")$par
      
      
    }, silent = TRUE)
    
    # if BFGS did not converge try Nelder-Mead
    if (class(try_est) == "try-error") {
      
      try_est <- try(expr = {
        
        # start optimization
        result <- optim(par = pars, 
                        fn = optim_fun,
                        obs = obs, 
                        m = m,
                        s = s,
                        method = "Nelder-Mead")$par
        
      }, silent = TRUE)
      
    }
    
    # if Nelder-Mead did not converge use initial values
    if (class(try_est) == "try-error") {
      
      result <- pars
      
    }
    
    # extract estimated parameters
    par <- data.frame(mu1 = result[1], mu2 = result[2],
                      sig1 = result[3], sig2 = result[4])
    
    # prepare output for forecast day k
    list(par = par,
         date = fds[k],
         location = location,
         length = l,
         log_sd = log_sd)
  }, mc.cores = cores)  
  
  # return output
  return(out)
  
}


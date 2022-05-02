options(stringsAsFactors = FALSE)
GetData <- function(apath = path) {
  tab <- fread(apath, sep = ';', dec = ',', header = FALSE,
               na.strings = c('#Н/Д'))	
  print(head(tab))			   
  tab[, V1 := as.Date(V1, format = '%d.%m.%Y')]
  names(tab)[1] <- "Date"
  print('#Н/Д')
na.omit(tab)
}

GetMusAndSigmas <- function(tab, indstart = NA, indend = NA) {
  tab <- as.data.table(as.data.frame(tab))
  if (is.na(indstart)) {
    indstart <- 1
  }
  if (is.na(indend)) {
    indend <- nrow(tab)
  }
  tab <- tab[indstart:indend, ]
  tab <- tab[, 2:ncol(tab), with = FALSE]
  mus <- tab[, lapply(.SD, mean)]
  sigmas <- cov(tab)
return(list(mu=mus, sigma=sigmas))
}

MarkowitzOptim <- function(q, mu, sigma) {
  solve.QP(Dmat = 2*sigma, dvec = q*mu, Amat = cbind(rep(1, nrow(sigma)), diag(nrow(sigma))), bvec = c(1, rep(0, nrow(sigma))), meq = 1)$solution
}

#KellyOptim <- function(mu, sigma, q=0) {
#  0.75*(1+q)*solve(sigma)%*%(mu-q)
#}

GetOptimKefs <- function(q, tab, optimmethod, winsize = 30) {
  htab <- as.data.table(as.data.frame(tab))
  res <- c()
  for (j in (winsize):nrow(tab)) {
    info  <- GetMusAndSigmas(tab, (j-winsize+1), j)
	kefs <- optimmethod(q, info$mu, info$sigma)
	if (j == winsize) {
	  res <- rbind(c(), c(kefs, j))
	} else {
	  res <- rbind(res, c(kefs, j))
	}
  }
res
}

CalculateFinResByPortfolio <- function(tab, porttab) {
  prices <- c()
  ws <- c()
  portpart <- 0
  changepart <- 0
  cash <- rep(NA, nrow(porttab)-1)
  ports <- rep(NA, nrow(porttab)-1)
  #print(head(tab))
  for (k in 1:(nrow(porttab)-1)) {
	j <- as.numeric(porttab[k, ncol(porttab), with = FALSE])
  	pricesnew <- tab[j+1, 2:ncol(tab), with = FALSE]
    if (length(prices) > 0) {
	  cash[k] <- round(portpart +  sum(ws*pricesnew), 6)
	  wsnew <- round(cash[k]*porttab[k, 1:(ncol(porttab)-1), with = FALSE]/pricesnew, 6)
	  #portpart <- round(portpart + sum((wsnew - ws)*pricesnew), 6) #+ sum(wsnew*(pricesnew-prices)), 6)
	  cash[k] <- round(portpart + sum(wsnew*pricesnew), 6)
	  ports[k] <- portpart
	} else {
	  cash[1] <- 1000000
	  ports[1] <- 0
	  wsnew <- cash[1]*porttab[k, 1:(ncol(porttab)-1), with = FALSE]/pricesnew
	  pricesfirst <- tab[j+1, 2:ncol(tab), with = FALSE]
	  wsfirst <- wsnew
	}
	prices <- pricesnew
	ws <- wsnew
  }
list(cash = cash, port = ports, dates = tab[as.numeric(porttab[1, ncol(porttab), with = FALSE] + 1):nrow(tab), 1, with = FALSE])
}

MainProc <- function(q, winsize = 30, apath = path) {
  tab <- GetData(apath)
  porttab <- as.data.table(GetOptimKefs(q, tab, MarkowitzOptim, winsize))
  finres <- CalculateFinResByPortfolio(tab, porttab)
  MakeResGraph(finres$cash, finres$dates)
}

MakeResGraph <- function(cash, dates) {
  cashvec <- diff(cash)
  sharp <- mean(cashvec)/sd(cashvec)
  sortino <- mean(cashvec)/sd(cashvec[cashvec < 0])
  valatrisk <- quantile(cashvec, 0.05)
  #print(c(sharp, sortino, as.numeric(valatrisk))) 
  layout(matrix(1:2, 2, 1))
  plot(dates, cash, xlab = 'Дата', ylab = 'Прибыль')
  plot(c(0, 1), c(0, 1), ann = FALSE, bty = 'n', type = "n", xaxt = "n", yaxt = "n")
  acol <- 'red'
  text(x = 0.1, y = 0.8, paste("Коэффициент шарпа", round(sharp, 4)), cex = 1.3, col = acol, adj = c(0, 0))
  text(x = 0.1, y = 0.6, paste("Коэффициент сортино", round(sortino, 4)), cex = 1.3, col = acol, adj = c(0, 0))
  text(x = 0.1, y = 0.4, paste("5%-й value at risk", round(valatrisk, 4)), cex = 1.3, col = acol, adj = c(0, 0))
}

MainProcAlt <- function(q, kefs, winsize = 30, apath = path) {
  tab <- GetData(apath)
  porttab <- do.call("rbind", replicate(nrow(tab)-winsize+1, kefs, simplify = FALSE))
  porttab[, ind := seq(winsize, nrow(tab))]
  finres <- CalculateFinResByPortfolio(tab, porttab)
  MakeResGraph(finres$cash, finres$dates)
}
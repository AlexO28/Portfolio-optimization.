chooseCRANmirror(ind=58)
if (!require('data.table',character.only = TRUE)) {
   install.packages('data.table',dep=TRUE) 
}
if (!require('quadprog',character.only = TRUE)) {
   install.packages('quadprog',dep=TRUE) 
}
if (!require('shiny',character.only = TRUE)) {
   install.packages('shiny',dep=TRUE) 
}
library(data.table)
library(quadprog)
library(shiny)
runApp("C:\\SpbCapital", launch.browser=TRUE)
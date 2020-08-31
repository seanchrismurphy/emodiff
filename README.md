# emodiff
Calculate emotion differentiation measures

## Overview
The emodiff package contains a single function that calculates three differention emotion differentiation indices and their inverses, for use on momentary assessment data of emotion.

## Use
You'll first want to install R and Rstudio (see [here](https://www.researchgate.net/publication/316678011_A_Psychologist's_Guide_to_R]) for a quick walkthrough of that process, which is quite simple.)

Once you have RStudio installed and open, using the emodiff package is simple. The first time you want to use it, you'll need to run the following code to install it. Paste this code into the command line of RStudio and hit run:

```
install.packages('devtools')
library(devtools)
install_github("seanchrismurphy/emodiff")
library(emodiff)
```

After that, you're ready to use the calculate_ed function on your data. An example on toy data:

```
calculate_ed(dat = emo_ex, emotions = c("happy","relaxed","cheerful"), id)

```


To learn more about the function, type `?calculate_ed` at the command line.

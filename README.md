# Multiwindow Shiny Example

## README Outline

* What is Multiwindow Shiny (MWS)?
* Overview
* Setup
* IDEA Server Considerations
* Contact

## What is Multiwindow Shiny (MWS)?

I'm glad you asked! It's pretty much what is written on the tin: a R Shiny application with multiple windows that work in tandem. The typical MWS application has 4 windows: a controller, wall, floor, and monitor (since MWS was made with the RPI  [campfire](http://empac.rpi.edu/content/campfire) in mind). In this typical structure, a controller contains selections for user inputs, while the wall, floor, and monitor views display output. However, a MWS application can have any number of windows (even simply two!).

## Overview

This repository provides a default example (Fruit Multiwindow Shiny Example) for MWS applications, including best practices. This work is based on Nick Thompson's initial implementation ([app](https://github.com/TheRensselaerIDEA/swotr/blob/master/campfire_demo.R), [library](https://github.com/TheRensselaerIDEA/swotr/blob/master/campfire_lib.R)) for MWS; however, his example was very bare bones, which is not conducive to practical applications. The Fruit MWS example shows an application with several plots, text, data loading, and a controller with multiple inputs and an action button.

In addition to the example code, an outline of MWS code workflow is also available, multiwindow_shiny_code_workflow.png. This is intended to provide an idea for the flow of editing code, from user inputs to outputs.

Other user submitted examples are also available in the "Other Examples" folder. If you would like to submit a MWS example, please contact Hannah De los Santos (information below).

The data for the Fruit MWS example comes from the [USDA](https://www.ers.usda.gov/data-products/fruit-and-tree-nut-data/fruit-and-tree-nut-yearbook-tables/#General).

## Setup

To run the Fruit MWS example, download that folder. Then, after opening R, install necessary packages (if you do not have them) with the following code:

```{r}
install.packages("shiny")
install.packages("ggplot2")
install.packages("reshape2")
install.packages("emojifont")
```

Then run all the code in fruit_campfire_app.R and a Shiny window should open automatically.

## IDEA Server Considerations

If you choose to set up a MWS application as a linked Shiny application on the IDEA server (through the ShinyApps folder), you must make several edits:

1. The "app" file must be named "app.R".
2. Delete the setwd line (the working directory of any application is automatically set to the folder where app.R resides)

After these edits are made, users should be able to access your application through your link with no problem.

## Contact

If you have any questions/comments/concerns, or want to submit another MWS example, please contact:

Hannah De los Santos /
email: delosh@rpi.edu /
Rensselaer Polytechnic Institute


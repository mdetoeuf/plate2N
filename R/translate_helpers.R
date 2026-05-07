
pipette_to_row <- function(pipetting_direction) {
  if (pipetting_direction == "top_down") {
    blank_should_be_in <- "A"
  } else if (pipetting_direction == "bottom_up") {
    blank_should_be_in <- "H"
  } else {stop("Unknown pipetting direction. Choose between `top-down` and `bottom_up`")}
  return(blank_should_be_in)
}

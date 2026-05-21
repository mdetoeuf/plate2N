## code to prepare `lm_output` dataset goes here

usethis::use_data(lm_output, overwrite = TRUE)

std_data <- std_corrected |> dplyr::group_by(plate_id, column)
lm_data <- lm_std_curve(std_data)
suspicious_lm <- suspicious_lm(lm_data)

plot_list_all <- plot_list_lm(lm_data,std_data)
plot_list_suspicious <- plot_list_lm(suspicious_lm,std_data)

lm_output <- list(
  "lm_data" = lm_data,
  "suspicious_lm" = suspicious_lm,
  "plot_list_suspicious" = plot_list_suspicious
)

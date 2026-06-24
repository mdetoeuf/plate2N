A pipeline that imports and tidies raw 96-well plate data, then
translates raw absorbance data into concentrations of Nitrogen species
(e.g., ammonium). This translation includes blank-correction of
absorbance and application of plate-level regression equations for
standard curves. plate2N also provides several quality checks,
supporting decisions to remove outliers, and proposes functions to do
so. Although it is designed to support data analysis for dosage of
Nitrogen compounds using absorbance readings, we believe that plate2N
could be used for any dosage based on absorbance readings, as long as
the relation between absorbance and concentration is linear or
polynomial (2nd degree). We are also currently developping adaptations
to the pipeline to fit the needs of a MicroResp assay. Stay tuned and
feel free to reach out to the authors to propose or discuss adaptations
to match your analytical needs, including additional models.

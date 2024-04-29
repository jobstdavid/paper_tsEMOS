
# Time Series based Ensemble Model Output Statistics for Temperature Forecasts Postprocessing

This repository provides supplementary material for the following paper:

> Jobst, D., Möller, A., and Groß, J. 2024. Time Series based Ensemble
> Model Output Statistics for Temperature Forecasts Postprocessing.
> (preprint version available at
> <https://doi.org/10.48550/arXiv.2402.00555>)

## Data

The data needed for reproducing the results is publicly available:

> Jobst, David, Möller, Annette, & Groß, Jürgen. (2023). Data set for
> the ensemble postprocessing of 2m surface temperature forecasts in
> Germany for five different lead times (0.1.0) \[Data set\]. Zenodo.
> <https://doi.org/10.5281/zenodo.8193645>

For the data license see
[here](https://github.com/jobstdavid/paper_tsEMOS/blob/main/DATA_LICENSE).

### ECMWF forecasts

- Source: [ECMWF](https://www.ecmwf.int) (European Centre for
  Medium-Range Weather Forecasts)
- Gridded forecasts: 50-member ensemble forecasts
- Time range: 2015-01-02 to 2020-12-31
- Forecast leadtimes: 24, 48, 72, 96, 120 hours
- Forecast initialization time: 12 UTC
- Area: Germany
- Resolution: 0.25 degrees
- Meteoroical variable: [2m surface
  temperature](https://codes.ecmwf.int/grib/param-db/?id=167) (t2m)

### DWD observations

- Source: [DWD Climate Data
  Center](https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/hourly/air_temperature/historical/BESCHREIBUNG_obsgermany_climate_hourly_tu_historical_de.pdf)
  ([German Weather Service](https://www.dwd.de))
- Observation data: Hourly observations of the target variable (2m
  surface temperature)
- Number of stations: 462
- ECMWF forecasts: Bilinearly interpolated to the SYNOP stations and
  reduced to its mean (t2m_mean) and standard deviation (t2m_sd)
- Metadata

| Variable | Description                           |
|----------|---------------------------------------|
| obs      | Observation of 2m surface temperature |
| lt       | Lead time                             |
| id       | Station ID                            |
| name     | Station name                          |
| lon      | Longitude of station                  |
| lat      | Latitude of station                   |
| elev     | Elevation of station                  |
| date     | Date                                  |
| doy      | Day of the year                       |

## Ensemble postprocessing

All models except of the EMOS and autoregressive adjusted EMOS (AR-EMOS)
are estimated based on the static training data 2015-2019. For the EMOS
and AR-EMOS model estimation a day-by-day sliding training window is
applied which uses training data of 2019 and 2020. Finally, all models
are evaluated in the whole year 2020.

### R-packages and R-Scripts for the ensemble postprocessing models

- `EMOS.R`: Local EMOS with rolling training period.
- [ensAR](https://github.com/JuGross/ensAR): Local autoregressive
  adjusted EMOS (AR-EMOS) with rolling training period.
- [tsEMOS](https://github.com/jobstdavid/tsEMOS):
  - Local smooth EMOS (SEMOS).
  - Local deseasonalized autoregressive smooth EMOS (DAR-SEMOS).
  - Local multiplicative deseasonalized autoregressive smooth EMOS with
    generalized autoregressive conditional heteroscedasticity
    (DAR-GARCH-SEMOS ($\cdot$)).
  - Local additive deseasonalized autoregressive smooth EMOS with
    generalized autoregressive conditional heteroscedasticity
    (DAR-GARCH-SEMOS (+)).
  - Local standardized autoregressive smooth EMOS (SAR-SEMOS).

### Additional R-packages

- [imputeTS](https://cran.r-project.org/web/packages/imputeTS/index.html):
  For the missing value imputation.
- [eppverification](https://github.com/jobstdavid/eppverification): For
  the verification of the ensemble postprocessing models.

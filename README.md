
# Compound Climate Extremes in Southeastern Türkiye

## Trends in Drought, Heavy Precipitation and Temperature Extremes (1990–2025)

[![Research](https://img.shields.io/badge/Research-Climate%20Extremes-blue)]()
[![Data](https://img.shields.io/badge/Data-NASA%20POWER-orange)]()
[![Period](https://img.shields.io/badge/Period-1990--2025-green)]()
[![Region](https://img.shields.io/badge/Region-Southeastern%20Türkiye-red)]()

---

## Overview

This project investigates the spatial and temporal characteristics of
compound climate extremes across Southeastern Türkiye during the
1990–2025 period.

The study focuses on the interaction between:

- Drought
- Extreme precipitation
- Temperature extremes
- Compound drought–heat events
- Drought-to-flood transitions

The analysis aims to identify changes in the frequency, intensity and
spatial distribution of climate extremes across the region.

---

## Study Area

The study covers nine provinces of Southeastern Türkiye:

- Adıyaman
- Batman
- Diyarbakır
- Gaziantep
- Kilis
- Mardin
- Siirt
- Şanlıurfa
- Şırnak

The regional analysis allows comparison of climate-extreme behavior
between different climatic and geographical settings.

---

## Research Questions

The project addresses the following research questions:

1. How have drought conditions changed across Southeastern Türkiye
   between 1990 and 2025?

2. Have extreme precipitation events become more frequent or intense?

3. Have temperature extremes increased during the study period?

4. Are drought and heat extremes occurring simultaneously more frequently?

5. Are transitions from prolonged dry conditions to extreme precipitation
   becoming more frequent?

6. Which provinces show the strongest changes in compound climate extremes?

---

## Data

### NASA POWER

Meteorological data will be obtained from the
NASA Prediction of Worldwide Energy Resources (POWER) project.

Primary variables include:

- Precipitation
- Mean air temperature
- Maximum air temperature
- Minimum air temperature

Additional variables may include:

- Relative humidity
- Wind speed
- Solar radiation

### Temporal Resolution

Monthly data will primarily be used for the period:

**1990–2025**

---

## Methodology

The analysis consists of five major components.

### 1. Drought Analysis

Drought conditions will be evaluated using:

- SPI-3
- SPI-12

Different accumulation periods will allow both short-term and
long-term drought conditions to be examined.

---

### 2. Extreme Precipitation Analysis

Precipitation extremes will be evaluated using indicators such as:

- Annual precipitation
- Maximum monthly precipitation
- Consecutive Dry Days (CDD)
- Consecutive Wet Days (CWD)
- Heavy precipitation frequency

---

### 3. Temperature Extremes

Temperature variability and extremes will be examined using:

- Mean temperature
- Maximum temperature
- Minimum temperature
- Temperature anomalies
- Extreme heat frequency
- Extreme cold frequency

Percentile-based thresholds will be considered for the identification
of temperature extremes.

---

### 4. Trend and Change-Point Analysis

Long-term changes will be evaluated using:

- Mann–Kendall Trend Test
- Sen's Slope Estimator
- Pettitt Change-Point Test

These methods will be applied to individual climate indicators and
compound-event frequencies.

---

### 5. Compound Climate Extremes

The main component of the project is the identification of compound
events.

Potential event categories include:

#### Compound Drought–Heat Events

Simultaneous occurrence of:

**Drought condition + extreme temperature**

#### Drought-to-Flood Transitions

Occurrence of:

**Prolonged dry conditions → extreme precipitation**

The frequency and spatial distribution of these events will be
investigated across the nine provinces.

---

## Workflow

```text
NASA POWER Data
       ↓
Data Cleaning
       ↓
Quality Control
       ↓
Monthly Climate Dataset
       ↓
Drought Indices
       ↓
Precipitation Extremes
       ↓
Temperature Extremes
       ↓
Trend Analysis
       ↓
Change-Point Detection
       ↓
Compound Event Detection
       ↓
Spatial Analysis
       ↓
Figures and Results

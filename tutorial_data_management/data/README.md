# Data Files

---

## Entity Relationship Diagram

```bash
|--------------------------------|
|      SamplingLocations         |
|--------------------------------|
| location_id (PK)               |
| location_name                  |
| latitude                       |
| longitude                      |
| date_sampled                   |
| depth_m                        |
| habitat_type                   |
|--------------------------------|
              |
              | 1
              |
              | N
|--------------------------------|
|       MorphologyData           |
|--------------------------------|
| individual_id (PK)             |
| location_id (FK)               |
| species                        |
| length_mm                      |
| weight_g                       |
| age                            |
| sex                            |
|--------------------------------|
```

---

## `sampling_locations.csv`:

Each row is a unique combination of location and date

Columns:

* location_id: Unique identifier for each sampling location.

* location_name: Name of the sampling location.

* latitude: Latitude coordinate of the location.

* longitude: Longitude coordinate of the location.

* date_sampled: Date when the location was sampled.

* depth_m: Depth at which the sample was taken, in meters.

* habitat_type: Type of habitat at the sampling location (e.g., Reef, Sand, Seagrass, Rocky).

---

## `morphology_data.csv`:

Each row is a unique individual

Columns: 

* individual_id: Unique identifier for each individual sampled.

* location_id: Identifier linking the individual to the sampling location (foreign key from sampling_locations.csv).

* species: Species of the individual.

* length_mm: Length of the individual in millimeters.

* weight_g: Weight of the individual in grams.

* age: Age of the individual in years.

* sex: Sex of the individual (M for male, F for female).
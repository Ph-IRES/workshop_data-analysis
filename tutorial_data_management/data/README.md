# Data Files

---

## Entity Relationship Diagram

```bash
|--------------------------------|
|     sampling_locations.csv     |
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
|      morphology_data.csv       |
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

In the entity-relationship diagram (ERD), the "1" and the "N" on the line between the two entities indicate a one-to-many relationship. Here's what they mean:

* `1`: This denotes that each record in the SamplingLocations table can be associated with one or more records in the MorphologyData table. In other words, a single sampling location can have multiple morphological data entries.

* `N`: This signifies that each record in the MorphologyData table is associated with exactly one record in the SamplingLocations table. In other words, each individual in the morphology data is linked to one specific sampling location.

This notation helps to understand how the tables are related: one sampling location (1) can be linked to many (N) morphological data entries.

In the entity-relationship diagram (ERD), PK and FK stand for:

* `PK (Primary Key)`: This is a unique identifier for each record in a table. It ensures that each record can be uniquely identified. In the diagram, location_id is the primary key for the SamplingLocations table, and individual_id is the primary key for the MorphologyData table.

* `FK (Foreign Key)`: This is a field in one table that uniquely identifies a row of another table. The foreign key creates a link between the two tables. In the diagram, location_id in the MorphologyData table is a foreign key that references location_id in the SamplingLocations table. This establishes the relationship between the two tables, indicating that each morphological data entry is associated with a specific sampling location.
	

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
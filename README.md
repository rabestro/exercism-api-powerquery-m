# Power Query Functions for Exercism API

This repository contains Power Query functions for fetching data from the Exercism API.

## Functions

### 1.  `Tracks()`

* **File:** `Tracks.pq` (Regular Query)
* **Description:** This query fetches a list of tracks from the Exercism API and returns a table with track details.
* **Usage:**
    1.  Import the `Tracks.pq` file into Power Query.
    2.  Create a new query and reference the `Tracks` query.
    3.  The output will be a table with the following columns:
        * `slug` (text): The track's unique identifier.
        * `Title` (text): The track's title.
        * `Course` (logical): Indicates if the track is a course.
        * `Concepts` (number): The number of concepts in the track.
        * `Exercises` (number): The number of exercises in the track.
        * `web` (text): The URL of the track on Exercism.
        * `tags` (text): A comma-separated string of tags associated with the track.

### 2.  `Exercises(track)`

* **File:** `Exercises.pq` (Function)
* **Description:** This function fetches a list of exercises for a specific track from the Exercism API and returns a table with exercise details.
* **Parameters:**
    * `track` (text): The slug of the track for which to fetch exercises.
* **Usage:**
    1.  Import the `Exercises.pq` file into Power Query.
    2.  Create a new blank query.
    3.  In the formula bar, invoke the function: `Exercises("track-slug")`, replacing `"track-slug"` with the desired track slug (e.g., `"java"`, `"python"`, `"csharp"`).
    4.  The output will be a table with the following columns:
        * `slug` (text): The exercise's unique identifier.
        * `Type` (text): The type of exercise.
        * `Title` (text): The exercise's title.
        * `Difficulty` (text): The exercise's difficulty level.
        * `Blurb` (text): A short description of the exercise.
        * `IsExternal` (logical): Indicates if the exercise is external.
        * `IsUnlocked` (logical): Indicates if the exercise is unlocked.
        * `IsRecommended` (logical): Indicates if the exercise is recommended.

![exercises-awk.png](assets/exercises-awk.png)

## Prerequisites

* Power Query Editor (Power BI Desktop, Excel, or Power Query for Dataflows).
* Internet connectivity to access the Exercism API.

## Setup

1.  Download the `.pq` files.
2.  Open Power BI Desktop or Excel.
3.  Open the Power Query Editor.
    * In Power BI Desktop: Go to `Home` tab -> `Transform Data`.
    * In Excel: Go to `Data` tab -> `Get & Transform Data` -> `From File` -> `From File`.
4.  Import the `.pq` files.
5.  Use the functions as described in the "Usage" sections above.

## Additional Notes

* The functions include error handling for API connection and JSON parsing issues.
* Ensure that the track slugs used with the `GetExercismExercises` function are valid.
* The data returned by these functions depends on the structure of the Exercism API.  Any changes to the API may require updates to the functions.

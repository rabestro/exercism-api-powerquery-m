# Power Query M for Exercism API

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Welcome! This repository provides Power Query M scripts (a query and a function) to easily fetch data directly from the Exercism.org API. This allows you to pull information about language tracks and their exercises into environments like Excel or Power BI for analysis, reporting, or, as in my case, track maintenance!

## Overview

Currently, two main scripts are available:

1.  **`Tracks`**: A query that retrieves a comprehensive list of all language tracks available on Exercism.
2.  **`Exercises`**: A function that fetches all exercises for a specified language track.

These scripts are designed to be robust, including basic error handling for API connectivity and JSON parsing.

## Available Scripts

### 1. `Tracks` (Query)

* **File:** [`powerquery/Tracks.pq`](powerquery/Tracks.pq)
* **Type:** Query (Self-executing when loaded)
* **Description:** Fetches a list of all language tracks from the Exercism API, providing details for each.
* **Output Columns:**
    * `slug` (text): The unique identifier for the track (e.g., "csharp", "awk").
    * `Title` (text): The display name of the track (e.g., "C#", "AWK").
    * `Course` (logical): `true` if the track is structured as a course, `false` otherwise.
    * `Concepts` (Int64.Type): The number of concepts taught in the track.
    * `Exercises` (Int64.Type): The total number of exercises available in the track.
    * `WebUrl` (text): The direct URL to the track page on the Exercism website.
    * `Tags` (text): A comma-separated string of tags associated with the track (e.g., "Object-oriented, Statically-typed").
* **Usage:**
    1.  Import `Tracks.pq` into your Power Query environment (see Setup).
    2.  The query will execute automatically. You can then reference this `Tracks` query as a data source in other queries or load it directly.

### 2. `Exercises` (Function)

* **File:** [`powerquery/Exercises.pq`](powerquery/Exercises.pq)
* **Type:** Function
* **Description:** Fetches a list of all exercises for a *specific* language track from the Exercism API.
* **Parameter:**
    * `trackName` (text): The slug of the track for which to fetch exercises (e.g., `"bash"`, `"elixir"`, `"awk"`).
* **Output Columns:**
    * `slug` (text): The unique identifier for the exercise (e.g., "hello-world").
    * `Type` (text): The type of exercise (e.g., "concept", "practice", "tutorial").
    * `Title` (text): The display name of the exercise.
    * `Difficulty` (text): The difficulty level of the exercise (e.g., "easy", "medium").
    * `Blurb` (text): A short description of the exercise.
    * `IsExternal` (logical): `true` if the exercise content is hosted externally.
    * `IsUnlocked` (logical): `true` if the exercise is currently unlocked for the user (may depend on API authentication context, typically true for public data).
    * `IsRecommended` (logical): `true` if Exercism recommends this exercise.
* **Usage:**
    1.  Import `Exercises.pq` into your Power Query environment. This makes the `Exercises` function available.
    2.  To use it, create a new blank query or use an existing one. In the formula bar (or Advanced Editor), invoke the function:
        ```powerquery
        Exercises("your-track-slug")
        ```
        Replace `"your-track-slug"` with the actual slug, for example: `Exercises("awk")`.

  ![Example: AWK Exercises fetched using the Exercises function](assets/exercises-awk.png)

## Prerequisites

* A Power Query compatible environment:
    * Microsoft Excel (Windows or Mac)
    * Power BI Desktop
    * Power Query Online (Dataflows)
* Internet connectivity to reach the Exercism API (`https://exercism.org`).

## Setup & Installation

1.  **Download:** Clone this repository or download the individual `.pq` files from the [`powerquery/`](powerquery/) directory.
2.  **Import into Power Query:**
    * Open your Power Query Editor.
        * **Excel**: `Data` tab -> `Get Data` -> `Launch Power Query Editor...`.
        * **Power BI Desktop**: `Home` tab -> `Transform data`.
    * In the Power Query Editor, create a new query:
        * Right-click in the Queries pane -> `New Query` -> `Other Sources` -> `Blank Query`.
    * With the new blank query selected, click `Advanced Editor` on the `Home` tab.
    * Open the downloaded `.pq` file (e.g., `Tracks.pq` or `Exercises.pq`) in a text editor.
    * Copy the entire M code from the `.pq` file.
    * Paste it into the Advanced Editor, replacing any existing content.
    * Click `Done`.
    * **Rename the query** to a meaningful name (e.g., "Tracks" for `Tracks.pq`, and "Exercises" for `Exercises.pq`). This is especially important for the `Exercises` function so you can call it by that name.

Repeat the import process for each `.pq` file you intend to use.

## Advanced Usage Example

For a practical example of how to use the `Exercises` function to compare tracks (e.g., finding BASH exercises not yet in AWK), see:
[`HOW_TO_USE.md`](HOW_TO_USE.md)

## Notes & Troubleshooting

* **API Rate Limits:** Be mindful of potential API rate limits if making a very large number of requests in a short period.
* **API Changes:** The data returned by these scripts depends on the current structure of the Exercism API (v2). Future changes to the API might require updates to these M scripts.
* **Error Handling:** The scripts include `try...otherwise` blocks for basic network and JSON parsing errors. If you encounter persistent issues, check your internet connection and the Exercism API status.
* **Credentials:** For public data, anonymous access is typically sufficient. Power Query might ask you to configure access for `exercism.org`. Choose "Anonymous" if prompted for public data.

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to:
* Open an issue to report a bug or suggest an improvement.
* Fork the repository and submit a pull request with your changes.

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

# Power Query Extractor for Exercise Specifications

## Overview

This Power Query script extracts metadata and deprecation status for all exercises from a local clone of the `exercism/problem-specifications` repository. It's designed for Exercism maintainers and contributors to review this data in Microsoft Excel or Power BI.

## Prerequisites

* Microsoft Excel (2016 or later / Microsoft 365 subscription) or Power BI Desktop.
* A local clone of the [exercism/problem-specifications](https://github.com/exercism/problem-specifications) repository.
  * If you don't have it: `git clone https://github.com/exercism/problem-specifications.git`
* The Power Query script files (or the Excel/Power BI file containing them).

## Setup Instructions

### Key Parameter: `ExercismRepositoryPath`

This script requires you to set the `ExercismRepositoryPath` parameter. This parameter **must be the absolute path to the directory *containing* your local `problem-specifications` clone.**

The script constructs the path to the exercises like this: `ExercismRepositoryPath & "/problem-specifications/exercises/"`.

**Important:**
* Use `/` (forward slashes) as the path separator. Power Query handles this correctly on Windows, macOS, and Linux.
* The path must be absolute.

![power-query-editor.png](../../assets/power-query-editor.png)

## Running the Query & Viewing Results

1.  After setting the parameter and closing the Power Query Editor, the main query, `ExercisesTable`, should automatically refresh and load the data.
2.  If you need to refresh the data later (e.g., after pulling new changes to the local repository):
  * **In Excel:** Go to the `Data` tab and click `Refresh All`.
  * **In Power BI:** Click the `Refresh` button on the `Home` tab.
    The data will appear as a table in your Excel sheet or as a dataset in Power BI.

## Expected Output

You will get a table with the following columns for each exercise:

* `Name`: The slug/identifier of the exercise (from its folder name, e.g., `hello-world`).
* `title`: The display title of the exercise (from `metadata.toml`).
* `blurb`: A short description of the exercise (from `metadata.toml`).
* `source`: The credited source of the exercise, if any (from `metadata.toml`).
* `source_url`: A URL to the source, if any (from `metadata.toml`).
* `deprecated`: A boolean value (`TRUE` if the exercise is marked as deprecated via a `.deprecated` file, `FALSE` otherwise).
* `note`: The content of the `.deprecated` file (typically a reason or link to a discussion). This will be `null` if the exercise is not deprecated.

![common-exercises.png](../../assets/common-exercises.png)

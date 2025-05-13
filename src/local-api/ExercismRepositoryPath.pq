// ----------------------------------------------------------------------------------------------------
// PARAMETER DEFINITION: Exercism Repository Path
//
// This query defines the `ExercismRepositoryPath` parameter. This parameter is crucial for
// locating the exercise specification files.
//
// **IMPORTANT: HOW TO SET THIS PARAMETER**
//
// 1. **UPDATE THE PATH BELOW:**
//    You MUST change the example path: "/User/username/exercism"
//    to the **absolute path** of the directory that *CONTAINS* your local
//    `problem-specifications` repository clone.
//
//    For example, if your `problem-specifications` folder is at:
//      `/Users/jsmith/projects/exercism-development/problem-specifications/`
//    Then, this parameter should be set to:
//      `"/Users/jsmith/projects/exercism-development/"`
//
// 2. **ABSOLUTE PATH:** The path must be absolute. Relative paths will not work.
//
// 3. **USE FORWARD SLASHES (`/`):**
//    Power Query correctly interprets forward slashes for paths on Windows, macOS, and Linux.
//    Example: `"/path/to/your/folder/"`
//
// This parameter will be used by other queries to build the full path to the exercise files.
// ----------------------------------------------------------------------------------------------------
let
    // Define the parameter for the root path of the Exercism development area
    // This path should point to the directory containing the "problem-specifications" folder.
    ExercismRepositoryPath = "/User/username/exercism" meta [
        IsParameterQuery = true,
        IsParameterQueryRequired = true,
        Type = type text
    ]
in
    ExercismRepositoryPath

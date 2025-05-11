// Query Name: ListDeprecatedExercises
// Description: This query identifies all common exercises (from the 'CommonExercises' query)
//              that have a '.deprecated' file in the problem-specifications repository
//              and lists them along with their deprecation notes.
// Depends on:
//   - 'CommonExercises' query: Provides the initial list of exercise slugs.
//   - 'GetExerciseDeprecationNote' function: Checks for and retrieves deprecation notes.
//   - (Optionally) 'GitHubAPIToken' parameter: Used by 'GetExerciseDeprecationNote' if defined.

let
    // Step 1: Start with the list of all common exercises
    // Assumes a query named 'CommonExercises' exists and returns a table with a 'slug' column.
    AllCommonExercises = CommonExercises,

    // Step 2: Add a column to get the deprecation note for each exercise
    // This calls the 'GetExerciseDeprecationNote' function for each slug.
    ExercisesWithDeprecationCheck = Table.AddColumn(
        AllCommonExercises,
        "DeprecationNote",
        each GetExerciseDeprecationNote([slug]) // Assuming 'slug' is the column name from CommonExercises
    ),

    // Step 3: Filter the table to keep only rows where a deprecation note exists (is not null)
    DeprecatedExercisesOnly = Table.SelectRows(
        ExercisesWithDeprecationCheck,
        each [DeprecationNote] <> null
    ),

    // Step 4: Select the relevant columns for the final output
    // We typically need the exercise slug and its deprecation note.
    // If 'CommonExercises' has other useful columns like 'Problem Specification URL',
    // you might want to include them here as well.
    FinalResult = Table.SelectColumns(DeprecatedExercisesOnly, {"slug", "DeprecationNote"}),

    // Step 5: Ensure correct data types for the final table
    TypedFinalResult = Table.TransformColumnTypes(FinalResult, {
        {"slug", type text},
        {"DeprecationNote", type text}
    })
in
    TypedFinalResult
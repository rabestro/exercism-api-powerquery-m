// Query Name: CommonExercisesWithMetadata
// Description: This query fetches common exercises from the 'problem-specifications' repository,
//              then enriches each exercise with metadata (title, blurb, source, etc.)
//              by calling the 'GetExerciseMetadata' function.
// Depends on:
//   - 'CommonExercises' query: Provides the initial list of exercise slugs and URLs.
//   - 'GetExerciseMetadata' function: Fetches metadata for a single exercise slug.
//   - (Optionally) 'GitHubAPIToken' parameter: Used by 'GetExerciseMetadata' if defined.
let
    // --- Main Query Logic Starts Here ---

    // Step 1: Reference the existing 'CommonExercises' query
    // This query is expected to return a table with at least a 'slug' column,
    // and ideally a 'Problem Specification URL' column.
    BaseExercisesTable = CommonExercises,

    // Step 2: Add a new column by invoking the external 'GetExerciseMetadata' function
    //         for each exercise slug.
    // This assumes 'BaseExercisesTable' has a 'slug' column (lowercase) and
    // the 'GetExerciseMetadata' function is available in the environment.
    ExercisesWithMetadataColumn = Table.AddColumn(
        BaseExercisesTable,
        "Metadata",
        each GetExerciseMetadata([slug]) // Calling the external function
    ),

    // Step 3: Expand the 'Metadata' record column to get individual metadata fields
    ExpandedExercisesWithMetadata = Table.ExpandRecordColumn(
        ExercisesWithMetadataColumn,
        "Metadata",
        {"title", "blurb", "source", "source_url", "error_message"}, // Fields from the metadata record
        {"Title", "Blurb", "Source", "SourceURL", "MetadataError"}  // New column names for these fields
    ),

    // Step 4: Select the final set of columns as requested
    // This ensures the output has the 'slug' and 'Problem Specification URL' from the CommonExercises query,
    // plus the newly fetched metadata.
    FinalColumnsSelected = Table.SelectColumns(
        ExpandedExercisesWithMetadata,
        {"slug", "Problem Specification URL", "Title", "Blurb", "Source", "SourceURL", "MetadataError"}
    ),

    // Step 5: Set data types for the final columns
    TypedResult = Table.TransformColumnTypes(
        FinalColumnsSelected,
        {
            {"slug", type text},
            {"Problem Specification URL", type text},
            {"Title", type text},
            {"Blurb", type text},
            {"Source", type text},
            {"SourceURL", type text},
            {"MetadataError", type text} // Column to indicate any errors during metadata fetching/parsing
        }
    )
in
    TypedResult

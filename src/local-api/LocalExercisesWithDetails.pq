// Query Name: LocalExercisesWithDetails
// Description: Fetches all common exercise slugs from the locally cloned 'problem-specifications'
//              repository and enriches each with metadata from their local 'metadata.toml' files
//              and deprecation status from local '.deprecated' files.
// Depends on:
//   - 'GetLocalExerciseSlugs' function: Lists exercise slugs from the local clone.
//   - 'GetLocalMetadata' function: Fetches local metadata for a single exercise slug.
//   - 'GetLocalDeprecationNote' function: Fetches local deprecation note for an exercise slug.
//   - 'ExercismReposRootPath' parameter: Used by the helper functions.

let
    // Step 1: Get the list of all local exercise slugs
    LocalSlugsList = GetLocalExerciseSlugs(),

    // Step 2: Convert the list of slugs into a table
    SlugsTable = Table.FromList(LocalSlugsList, Splitter.SplitByNothing(), {"slug"}, null, ExtraValues.Error),

    // Step 3: Filter out any null or error rows from slug listing
    ValidSlugsTable = Table.SelectRows(SlugsTable, each [slug] <> null and not Text.StartsWith([slug], "Error:")),

    // Step 4: Add metadata for each exercise
    ExercisesWithMetadata = Table.AddColumn(
        ValidSlugsTable,
        "Metadata",
        each GetLocalMetadata([slug])
    ),

    // Step 5: Add deprecation note for each exercise
    ExercisesWithDeprecation = Table.AddColumn(
        ExercisesWithMetadata,
        "DeprecationNoteText", // Temporary name
        each GetLocalDeprecationNote([slug])
    ),

    // Step 6: Expand the 'Metadata' record column
    ExpandedMetadata = Table.ExpandRecordColumn(
        ExercisesWithDeprecation,
        "Metadata",
        {"title", "blurb", "source", "source_url", "error_message"},
        {"Title", "Blurb", "Source", "SourceURL", "MetadataError"}
    ),

    // Step 7: Add the 'IsDeprecated' logical column
    AddedIsDeprecatedColumn = Table.AddColumn(
        ExpandedMetadata,
        "IsDeprecated",
        each [DeprecationNoteText] <> null, // True if DeprecationNoteText is not null
        type logical
    ),

    // Step 8: Select and rename columns for the final output
    FinalResult = Table.SelectColumns(
        AddedIsDeprecatedColumn,
        {
            "slug", "Title", "Blurb", "Source", "SourceURL",
            "IsDeprecated", "DeprecationNoteText", "MetadataError"
        }
    ),
    RenamedDeprecationNote = Table.RenameColumns(FinalResult, {{"DeprecationNoteText", "DeprecationNote"}}),


    // Step 9: Set data types for the final table
    TypedFinalResult = Table.TransformColumnTypes(RenamedDeprecationNote, {
        {"slug", type text},
        {"Title", type text},
        {"Blurb", type text},
        {"Source", type text},
        {"SourceURL", type text},
        {"IsDeprecated", type logical},
        {"DeprecationNote", type text},
        {"MetadataError", type text}
    })
in
    TypedFinalResult

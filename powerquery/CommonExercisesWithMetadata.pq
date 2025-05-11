// Query Name: CommonExercisesWithMetadata
let
    // Helper function to fetch and parse metadata.toml for a given exercise slug
    fxGetExerciseMetadata = (exerciseSlug as text) as record =>
        let
            MetadataURL = "https://raw.githubusercontent.com/exercism/problem-specifications/main/exercises/"
                & Uri.EscapeDataString(exerciseSlug)
                & "/metadata.toml",
            // Default record structure, also used in case of errors
            DefaultMetadataRecord = [
                title = null,
                blurb = null,
                source = null,
                source_url = null,
                error_message = null
            ],
            FetchedMetadata =
                try
                    let
                        WebContent = Web.Contents(
                            MetadataURL,
                            [
                                Headers = [#"User-Agent" = "PowerQuery-Exercism-Metadata-Fetcher"],
                                // Good practice to set User-Agent
                                Timeout = #duration(0, 0, 15, 0)
                                // 15-second timeout for individual file
                            ]
                        ),
                        TextContent = Text.FromBinary(WebContent, TextEncoding.UTF8),
                        Lines = Lines.FromText(TextContent),
                        // Inner helper to extract a value for a given key from TOML-like lines
                        GetValueFromLines = (textLines as list, keyName as text) as nullable text =>
                            let
                                LinePrefix = keyName & " = """,
                                MatchingLine = List.Select(textLines, each Text.StartsWith(_, LinePrefix)),
                                Value =
                                    if List.IsEmpty(MatchingLine) then
                                        null
                                    else
                                        // Extract text between the first quote after "key = "" and the closing quote on that line
                                        Text.BetweenDelimiters(List.First(MatchingLine), LinePrefix, """", 0, 0)
                            in
                                Value,
                        ExtractedTitle = GetValueFromLines(Lines, "title"),
                        ExtractedBlurb = GetValueFromLines(Lines, "blurb"),
                        ExtractedSource = GetValueFromLines(Lines, "source"),
                        ExtractedSourceURL = GetValueFromLines(Lines, "source_url")
                    in
                        [
                            title = ExtractedTitle,
                            blurb = ExtractedBlurb,
                            source = ExtractedSource,
                            source_url = ExtractedSourceURL,
                            error_message = null
                            // No error if successful
                        ]
                    // If Web.Contents or parsing fails, return default record with an error message
                otherwise
                    DefaultMetadataRecord & [error_message = "Failed to fetch or parse metadata from: " & MetadataURL]
        in
            FetchedMetadata,

    // --- Main Query Logic Starts Here ---

    // Step 1: Reference the existing 'CommonExercises' query
    // This query is expected to return a table with at least a 'slug' column,
    // and ideally a 'Problem Specification URL' column.
    BaseExercisesTable = CommonExercises,

    // Step 2: Add a new column by invoking the helper function to get metadata for each exercise
    // This assumes 'BaseExercisesTable' has a 'slug' column (lowercase).
    ExercisesWithMetadataColumn = Table.AddColumn(BaseExercisesTable, "Metadata", each fxGetExerciseMetadata([slug])),

    // Step 3: Expand the 'Metadata' record column to get individual metadata fields
    ExpandedExercisesWithMetadata = Table.ExpandRecordColumn(
        ExercisesWithMetadataColumn,
        "Metadata",
        {"title", "blurb", "source", "source_url", "error_message"},
        // Fields from the metadata record
        {"Title", "Blurb", "Source", "SourceURL", "MetadataError"}
        // New column names for these fields
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
            // Changed from ExerciseSlug
            {"Problem Specification URL", type text},
            // Changed from ProblemSpecificationURL
            {"Title", type text},
            {"Blurb", type text},
            {"Source", type text},
            {"SourceURL", type text},
            {"MetadataError", type text}
            // Column to indicate any errors during metadata fetching/parsing
        }
    )
in
    TypedResult

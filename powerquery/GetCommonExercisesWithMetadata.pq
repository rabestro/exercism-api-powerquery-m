// Query Name: GetCommonExercisesWithMetadata
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
                            MetadataURL, [
                                Headers = [#"User-Agent" = "PowerQuery"],
                                Timeout = #duration(0, 0, 15, 0)
                                // 15-second timeout for individual file
                            ]
                        ),
                        TextContent = Text.FromBinary(WebContent, TextEncoding.Utf8),
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

    // Define the GitHub API URL for the problem-specifications exercises directory
    SourceURL = "https://api.github.com/repos/exercism/problem-specifications/contents/exercises?ref=main",
    // Fetch the list of exercises from the GitHub API
    WebContent = Web.Contents(
        SourceURL,
        [
            Headers = [
                #"Accept" = "application/vnd.github.v3+json",
                // Recommended by GitHub API
                #"User-Agent" = "PowerQuery"
            ],
            Timeout = #duration(0, 0, 30, 0)
            // 30-second timeout for the main list
        ]
    ),
    // Parse the JSON response for the list of exercises
    ParsedJson =
        try
            Json.Document(WebContent)
        otherwise
            error
                "Failed to parse JSON from GitHub API. URL: "
                    & SourceURL
                    & ". Response: "
                    & Text.FromBinary(WebContent, TextEncoding.UTF8),
    // Convert the list of exercise records (files and directories) into a table
    SourceTable = Table.FromList(ParsedJson, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    // Expand the 'Column1' which contains the records for each item
    ExpandedContent = Table.ExpandRecordColumn(
        SourceTable, "Column1", {"name", "path", "type", "html_url"},
        // Fields to expand
        {"Name", "Path", "Type", "HtmlURL"}
        // New column names
    ),
    // Filter the table to include only directories, as exercises are represented by directories
    FilteredToDirectories = Table.SelectRows(ExpandedContent, each ([Type] = "dir")),
    // Select and rename columns for the base exercise list
    BaseExercisesTable = Table.SelectColumns(FilteredToDirectories, {"Name", "HtmlURL"}),
    RenamedBaseTable = Table.RenameColumns(
        BaseExercisesTable, {{"Name", "ExerciseSlug"}, {"HtmlURL", "ProblemSpecificationURL"}}
    ),
    // Add a new column by invoking the helper function to get metadata for each exercise
    ExercisesWithMetadataColumn = Table.AddColumn(
        RenamedBaseTable, "Metadata", each fxGetExerciseMetadata([ExerciseSlug])
    ),
    // Expand the 'Metadata' record column to get individual metadata fields
    ExpandedExercisesWithMetadata = Table.ExpandRecordColumn(
        ExercisesWithMetadataColumn,
        "Metadata",
        {"title", "blurb", "source", "source_url", "error_message"},
        // Fields from the metadata record
        {"Title", "Blurb", "Source", "SourceURL", "MetadataError"}
        // New column names for these fields
    ),
    // Select the final set of columns as requested
    FinalColumnsSelected = Table.SelectColumns(
        ExpandedExercisesWithMetadata,
        {"ExerciseSlug", "ProblemSpecificationURL", "Title", "Blurb", "Source", "SourceURL", "MetadataError"}
    ),
    // Set data types for the final columns
    TypedResult = Table.TransformColumnTypes(
        FinalColumnsSelected,
        {
            {"ExerciseSlug", type text},
            {"ProblemSpecificationURL", type text},
            {"Title", type text},
            {"Blurb", type text},
            {"Source", type text},
            {"SourceURL", type text},
            {"MetadataError", type text}
        }
    )
in
    TypedResult

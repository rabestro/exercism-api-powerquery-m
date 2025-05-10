// Query Name: GetCommonExercises
let
    // Define the GitHub API URL for the problem-specifications exercises directory
    SourceURL = "https://api.github.com/repos/exercism/problem-specifications/contents/exercises?ref=main",
    // Fetch the content from the API
    // GitHub API prefers an Accept header, though often works without for public repos.
    // Adding User-Agent is good practice.
    WebContent = Web.Contents(
        SourceURL,
        [
            Headers = [
                #"Accept" = "application/vnd.github.v3+json",
                #"User-Agent" = "PowerQuery"
            ],
            Timeout = #duration(0, 0, 30, 0)
            // 30-second timeout
        ]
    ),
    // Parse the JSON response
    // Includes error handling for invalid JSON
    ParsedJson =
        try
            Json.Document(WebContent)
        otherwise
            error
                "Failed to parse JSON from GitHub API. URL: "
                    & SourceURL
                    & ". Response: "
                    & Text.FromBinary(WebContent, TextEncoding.Utf8),
    // The response is a list of records (files and directories)
    // Convert this list into a table
    SourceTable = Table.FromList(ParsedJson, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    // Expand the 'Column1' which contains the records for each item
    ExpandedContent = Table.ExpandRecordColumn(
        SourceTable,
        "Column1",
        {"name", "path", "sha", "type", "html_url", "download_url"},
        {"Name", "Path", "SHA", "Type", "HtmlURL", "DownloadURL"}
    ),
    // Filter the table to include only directories, as exercises are represented by directories
    FilteredToDirectories = Table.SelectRows(ExpandedContent, each ([Type] = "dir")),
    // Select and rename the 'Name' column to 'slug' for clarity
    // This column contains the slugs of the common exercises
    SelectAndRenameColumns = Table.SelectColumns(FilteredToDirectories, {"Name", "HtmlURL"}),
    RenamedColumns = Table.RenameColumns(
        SelectAndRenameColumns, {{"Name", "slug"}, {"HtmlURL", "Problem Specification URL"}}
    ),
    // Set data types for the final columns
    TypedResult = Table.TransformColumnTypes(
        RenamedColumns, {{"slug", type text}, {"Problem Specification URL", type text}}
    )
in
    TypedResult

// Query Name: CommonExercises
let
    // Define the GitHub API URL for the problem-specifications exercises directory
    SourceURL = "https://api.github.com/repos/exercism/problem-specifications/contents/exercises?ref=main",

    // Define request headers, including the GitHub API Token if available
    RequestHeaders =
        let
            BaseHeaders = [
                #"Accept"="application/vnd.github.v3+json",
                #"User-Agent"="PowerQuery-ExercismClient/1.0 (+https://github.com/Rabestro/exercism-api-powerquery-m)"
            ],
            TokenValue = try GitHubAPIToken otherwise null // Safely check for GitHubAPIToken parameter
        in
            if TokenValue <> null and TokenValue <> "" then
                BaseHeaders & [#"Authorization"="token " & TokenValue] // Add Authorization if token exists
            else
                BaseHeaders, // Only BaseHeaders if no token

    // Fetch the content from the API
    WebContent = Web.Contents(
        SourceURL,
        [
            Headers = RequestHeaders,
            Timeout = #duration(0, 0, 30, 0) // 30-second timeout
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
                    & ". Response (first 500 chars): "
                    & Text.Start(Text.FromBinary(WebContent, TextEncoding.Utf8),500), // Show only start of response

    // The response is a list of records (files and directories)
    // Convert this list into a table
    SourceTable = Table.FromList(ParsedJson, Splitter.SplitByNothing(), null, null, ExtraValues.Error),

    // Expand the 'Column1' which contains the records for each item
    ExpandedContent = Table.ExpandRecordColumn(
        SourceTable,
        "Column1",
        {"name", "path", "sha", "type", "html_url", "download_url"}, // Fields to expand
        {"Name", "Path", "SHA", "Type", "HtmlURL", "DownloadURL"}  // New column names
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

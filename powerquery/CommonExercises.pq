// Query Name: CommonExercises
// Description: Fetches a list of common exercise slugs and their problem specification URLs
//              from the exercism/problem-specifications GitHub repository.
// Depends on:
//   - 'GetGitHubApiHeaders' function: Provides standard GitHub API request headers.
//   - (Optionally) 'GitHubAPIToken' parameter: Used by 'GetGitHubApiHeaders' if defined.
let
    // Define the GitHub API endpoint components
    BaseAPIURL = "https://api.github.com/repos/exercism/problem-specifications/contents/",
    ExercisePath = "exercises", // Relative path to the exercises directory

    // Get standard GitHub API headers by calling the helper function
    RequestHeaders = GetGitHubApiHeaders(),

    // Fetch the content from the API
    WebContent = Web.Contents(
        BaseAPIURL, // Base URL for the API
        [
            RelativePath = ExercisePath, // Path to the specific content
            Query = [ref = "main"],      // Query parameters, like the branch
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
                "Failed to parse JSON from GitHub API. Attempted URL: " // Clarified error message slightly
                    & BaseAPIURL & ExercisePath & "?ref=main"
                    & ". Response (first 500 chars): "
                    & Text.Start(Text.FromBinary(WebContent, TextEncoding.Utf8),500),

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

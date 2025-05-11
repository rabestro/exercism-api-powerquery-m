/*
    Description:
    This Power Query M query fetches a list of all available language tracks from the Exercism API.
    It returns a table with details for each track, such as its slug, title, number of
    concepts and exercises, web URL, and tags.

    API Token Usage (ExercismAPIToken Parameter):
    - This query is designed to optionally use an 'ExercismAPIToken' parameter.
    - If an 'ExercismAPIToken' parameter is defined in your Power Query environment and contains a valid
      Exercism API token, the query will include it in the request headers as an
      Authorization Bearer token.
    - Using a token can be beneficial for consistency if other API calls are authenticated,
      though for fetching public track listings, it's often not strictly necessary.
    - If the 'ExercismAPIToken' is not set or is empty, the API request will be made anonymously.

    Prerequisites for Token Usage:
    1. An 'ExercismAPIToken.pq' file (or a similarly defined parameter query) should exist in your
       Power Query environment, defining a parameter named 'ExercismAPIToken'.
    2. This parameter should hold your valid Exercism API token string.

    Usage:
    1. Load this file into Power Query (e.g., as a new blank query, then paste this code
       into the Advanced Editor).
    2. Name the query (e.g., "ExercismTracks").
    3. The query will execute and return the list of tracks.
*/
let
    // Define the source API endpoint for fetching all tracks
    API_URL = "https://exercism.org/api/v2/tracks",

    // Define request headers, including the Exercism API Token if available and User-Agent
    RequestHeaders =
        let
            UserAgentHeader = [#"User-Agent"="PowerQuery-ExercismClient/1.0 (+https://github.com/Rabestro/exercism-api-powerquery-m)"],
            TokenValue = try ExercismAPIToken otherwise null // Safely check for ExercismAPIToken parameter
        in
            if TokenValue <> null and TokenValue <> "" then
                [#"Authorization"="Bearer " & TokenValue] & UserAgentHeader // Add Authorization if token exists
            else
                UserAgentHeader, // Only User-Agent if no token

    // Fetch content from the API with a 30-second timeout and appropriate headers
    // Includes basic error handling for network/API issues
    WebContent =
        try
            Web.Contents(API_URL, [Headers = RequestHeaders, Timeout = #duration(0, 0, 30, 0)])
        otherwise
            error "Failed to fetch data from API. URL: " & API_URL,

    // Parse the JSON response
    // Includes error handling for invalid JSON structure
    JsonDocument =
        try
            Json.Document(WebContent)
        otherwise
            error "Invalid JSON response from API. Content received (first 500 chars): " & Text.Start(Text.FromBinary(WebContent, TextEncoding.Utf8), 500),

    // Extract the list of track records from the JSON structure
    // Assumes the JSON response has a top-level key "tracks" which is a list
    TrackRecordsList = JsonDocument[tracks],

    // Convert the list of track records into a table
    InitialTable = Table.FromList(TrackRecordsList, Splitter.SplitByNothing(), null, null, ExtraValues.Error),

    // Expand the nested record column to bring track details into separate columns
    ExpandedTracks = Table.ExpandRecordColumn(
        InitialTable,
        "Column1", // Default column name from Table.FromList
        // Original field names from JSON
        {"slug", "title", "course", "num_concepts", "num_exercises", "web_url", "tags"},
        // New, more descriptive and consistently cased column names
        {"slug", "Title", "HasCourse", "ConceptsCount", "ExercisesCount", "WebURL", "TagsList"}
    ),

    // Convert the "TagsList" (which is a list of tags) into a single comma-separated text string
    // Handles cases where TagsList might be null or not a list.
    FormattedTagsTable = Table.TransformColumns(
        ExpandedTracks,
        {"TagsList", each if _ is list then Text.Combine(_, ", ") else null, type text}
    ),

    // Define and apply the correct data types for each column for consistency and proper data handling
    TypedTracksTable = Table.TransformColumnTypes(
        FormattedTagsTable,
        {
            {"slug", type text},
            {"Title", type text},
            {"HasCourse", type logical},
            {"ConceptsCount", Int64.Type},
            {"ExercisesCount", Int64.Type},
            {"WebURL", type text},
            {"TagsList", type text} // This is now the comma-separated string of tags
        }
    )
in
    TypedTracksTable

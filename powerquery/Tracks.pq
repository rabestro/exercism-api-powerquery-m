/*
    This file contains a Power Query M query to fetch tracks from the Exercism API.
    The query returns a table with track details.

    Usage:
    1. Load this file into Power Query (e.g., as a new blank query and paste into Advanced Editor).
    2. The query will execute and return the list of tracks.
*/
let
    // Define the source API endpoint
    API_URL = "https://exercism.org/api/v2/tracks",

    // Fetch content from the API with a 30-second timeout
    // Includes basic error handling for network/API issues
    Content =
        try
            Web.Contents(API_URL, [Timeout = #duration(0, 0, 30, 0)])
        otherwise
            error "Failed to fetch data from API. URL: " & API_URL,

    // Parse the JSON response
    // Includes error handling for invalid JSON structure
    JsonDoc =
        try
            Json.Document(Content)
        otherwise
            error "Invalid JSON response from API. Content received: " & Text.FromBinary(Content),

    // Extract the list of tracks from the JSON structure
    // Assumes the JSON response has a top-level key "tracks" which is a list
    TrackRecords = JsonDoc[tracks],

    // Convert the list of track records into a table
    InitialTable = Table.FromList(TrackRecords, Splitter.SplitByNothing(), null, null, ExtraValues.Error),

    // Expand the nested record column to bring track details into separate columns
    ExpandedTracks = Table.ExpandRecordColumn(
        InitialTable,
        "Column1", // Default column name from Table.FromList
        {"slug", "title", "course", "num_concepts", "num_exercises", "web_url", "tags"},
        {"slug", "Title", "HasCourse", "ConceptsCount", "ExercisesCount", "WebURL", "TagsList"}
    ),

    // Convert the "TagsList" (which is a list) into a single comma-separated text string
    FormattedTags = Table.TransformColumns(
        ExpandedTracks, {"TagsList", each if _ is list then Text.Combine(_, ", ") else null, type text}
    ),

    // Define and apply the correct data types for each column
    TypedTracks = Table.TransformColumnTypes(
        FormattedTags,
        {
            {"slug", type text},
            {"Title", type text},
            {"HasCourse", type logical},
            {"ConceptsCount", Int64.Type},
            {"ExercisesCount", Int64.Type},
            {"WebURL", type text},
            {"TagsList", type text}
        }
    )
in
    TypedTracks

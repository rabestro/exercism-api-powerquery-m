/*
    This file contains a Power Query function to fetch exercises from the Exercism API.
    The function takes a track name as input and returns a table with exercise details.

    Usage:
    1. Save this query with a name, e.g., "GetTrackExercises".
    2. Call the function from another query or directly: GetTrackExercises("awk")
*/
(trackName as text) =>
    let
        // Construct the API URL for the specified track, ensuring the track name is URL-encoded
        API_URL = "https://exercism.org/api/v2/tracks/" & Uri.EscapeDataString(trackName) & "/exercises",

        // Fetch content from the API with a 30-second timeout and error handling
        WebContent =
            try
                Web.Contents(API_URL, [Timeout = #duration(0, 0, 30, 0)])
            otherwise
                error "Failed to fetch data from API for track '" & trackName & "'. URL: " & API_URL,

        // Parse the JSON response with error handling
        JsonDocument =
            try
                Json.Document(WebContent)
            otherwise
                error
                    "Invalid JSON response from API for track '"
                        & trackName
                        & "'. Received content might not be valid JSON. Raw content (first 500 chars): "
                        & Text.Start(Text.FromBinary(WebContent, TextEncoding.Utf8), 500),

        // Extract the list of exercise records from the JSON structure
        // Assumes JsonDocument has a top-level key "exercises" which is a list
        ExerciseRecordsList = JsonDocument[exercises],

        // Convert the list of exercise records into a table
        SourceTable = Table.FromList(ExerciseRecordsList, Splitter.SplitByNothing(), null, null, ExtraValues.Error),

        // Expand the nested record column to bring exercise details into separate columns
        ExpandedExercises = Table.ExpandRecordColumn(
            SourceTable,
            // Default column name from Table.FromList
            "Column1",
            // Original field names from JSON that we want to include
            {"slug", "type", "title", "difficulty", "blurb", "is_external", "is_unlocked", "is_recommended"},
            // New, more descriptive and consistently cased column names
            {"slug", "Type", "Title", "Difficulty", "Blurb", "IsExternal", "IsUnlocked", "IsRecommended"}
        ),

        // Define and apply the correct data types for each column
        TypedExercises = Table.TransformColumnTypes(
            ExpandedExercises,
            {
                {"slug", type text},
                {"Type", type text}, 
                {"Title", type text},
                {"Difficulty", type text},
                {"Blurb", type text},
                {"IsExternal", type logical},
                {"IsUnlocked", type logical},
                {"IsRecommended", type logical}
            }
        )
    in
        TypedExercises

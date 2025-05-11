/*
    Description:
    This Power Query function fetches exercise details for a specified track from the Exercism API.
    It takes a track name (e.g., "awk", "csharp") as input and returns a table
    containing information for each exercise, such as its slug, title, type, difficulty, and blurb.

    API Token Usage (ExercismAPIToken Parameter):
    - This function is designed to optionally use an 'ExercismAPIToken' parameter.
    - If an 'ExercismAPIToken' parameter is defined in your Power Query environment and contains a valid
      Exercism API token, the function will include it in the request headers as an
      Authorization Bearer token.
    - Benefits of using a token:
        - Access to user-specific data: Fields like 'IsUnlocked' and 'IsRecommended' will
          reflect your actual progress and recommendations on Exercism.
        - Potentially higher API rate limits (though generally not an issue for typical use).
    - If the 'ExercismAPIToken' is not set or is empty:
        - The API request will be made anonymously.
        - Fields like 'IsUnlocked' will likely show most exercises as true (public view), and
          'IsRecommended' may default to false or show generic, non-personalized values.

    Function Output:
    A table with columns: "slug", "Type", "Title", "Difficulty", "Blurb", "IsExternal",
                         "IsUnlocked", "IsRecommended".

    Prerequisites for Token Usage:
    1. An 'ExercismAPIToken.pq' file (or a similarly defined parameter query) should exist in your
       Power Query environment, defining a parameter named 'ExercismAPIToken'.
    2. This parameter should hold your valid Exercism API token string. (You can obtain this from
       Exercism.org -> Settings -> API / CLI Token).

    Basic Usage:
    1. Ensure this function query is loaded and named (e.g., "GetTrackExercises").
    2. To call it, you can create a new query and use:
       let
           Source = GetTrackExercises("your-track-slug")
       in
           Source
       Replace "your-track-slug" with the desired track (e.g., "elixir", "awk").
*/
(trackName as text) =>
    let
        // Construct the API URL for the specified track, ensuring the track name is URL-encoded
        API_URL = "https://exercism.org/api/v2/tracks/" & Uri.EscapeDataString(trackName) & "/exercises",

        // Define request headers, including the Exercism API Token if available
        RequestHeaders =
            let
                // User-Agent header to identify the request source
                UserAgentHeader = [#"User-Agent"="PowerQuery-ExercismClient/1.0 (+https://github.com/Rabestro/exercism-api-powerquery-m)"],
                // Attempt to retrieve the Exercism API token from the environment
                // This should be defined in your Power Query environment as a parameter
                TokenValue = try ExercismAPIToken otherwise null
            in
                if TokenValue <> null and TokenValue <> "" then
                    [#"Authorization"="Bearer " & TokenValue] & UserAgentHeader
                else
                    UserAgentHeader,

        // Fetch content from the API with a 30-second timeout, headers, and error handling
        WebContent =
            try
                Web.Contents(API_URL, [Headers = RequestHeaders, Timeout = #duration(0, 0, 30, 0)])
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
            // Original field names from JSON that you want to include
            {"slug", "type", "title", "difficulty", "blurb", "is_external", "is_unlocked", "is_recommended"},
            // New, more descriptive and consistently cased column names
            // Using lowercase 'slug' as per previous discussions for consistency with its typical use as an ID.
            {"slug", "Type", "Title", "Difficulty", "Blurb", "IsExternal", "IsUnlocked", "IsRecommended"}
        ),

        // Define and apply the correct data types for each column
        TypedExercises = Table.TransformColumnTypes(
            ExpandedExercises,
            {
                {"slug", type text},
                {"Type", type text},
                {"Title", type text},
                {"Difficulty", type text}, // As per API, difficulty is textual e.g. "easy"
                {"Blurb", type text},
                {"IsExternal", type logical},
                {"IsUnlocked", type logical},
                {"IsRecommended", type logical}
            }
        )
    in
        TypedExercises

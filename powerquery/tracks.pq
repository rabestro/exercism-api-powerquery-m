/*
    This file contains a Power Query function to fetch tracks from the Exercism API.
    The function returns a table with track details.

    Usage:
    1. Load this file into Power Query.
    2. Call the function to get the list of tracks.
*/
let
    API_URL = "https://exercism.org/api/v2/tracks",
    Content = try Web.Contents(API_URL, [Timeout=#duration(0, 0, 30, 0)]) otherwise error "Failed to fetch data from API",
    JsonDoc = try Json.Document(Content) otherwise error "Invalid JSON response from API",
    Tracks = Table.FromList(JsonDoc[tracks], Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    languages = Table.ExpandRecordColumn(
        Tracks,
        "Column1",
        {"slug", "title", "course", "num_concepts", "num_exercises", "web_url", "tags"},
        {"slug", "Title", "Course", "Concepts", "Exercises", "web", "tags"}
    ),
    // Convert the "tags" list column to a comma-separated string
    Tags = Table.TransformColumns(languages, {"tags", each Text.Combine(_, ", ")}),
    ChangedColumnType = Table.TransformColumnTypes(
        Tags,
        {
            {"Title", type text},
            {"Course", type logical},
            {"Concepts", Int64.Type},
            {"Exercises", Int64.Type},
            {"web", type text},
            {"tags", type text},
            {"slug", type text}
        }
    )
in
    ChangedColumnType

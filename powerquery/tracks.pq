let
    uri = "https://exercism.org/api/v2/tracks",
    content = Web.Contents(uri),
    jsonDoc = Json.Document(content),
    tracks = Table.FromList(jsonDoc[tracks], Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    languages = Table.ExpandRecordColumn(
        tracks,
        "Column1",
        {"slug", "title", "course", "num_concepts", "num_exercises", "web_url", "tags"},
        {"slug", "Title", "Course", "Concepts", "Exercises", "web", "tags"}
    ),
    // Convert the "tags" list column to a comma-separated string
    tags = Table.TransformColumns(languages, {"tags", each Text.Combine(_, ", ")}),
    ChangedColumnType = Table.TransformColumnTypes(
        tags,
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

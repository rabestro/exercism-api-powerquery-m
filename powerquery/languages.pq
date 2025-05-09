let
    uri = "https://exercism.org/api/v2/tracks",
    content = Web.Contents(uri),
    jsonDoc = Json.Document(content),
    tracks = Table.FromList(jsonDoc[tracks], Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    Languages = Table.ExpandRecordColumn(
        tracks,
        "Column1",
        {
            "slug",
            "title",
            "course",
            "num_concepts",
            "num_exercises",
            "web_url",
            "icon_url",
            "tags",
            "last_touched_at",
            "is_new",
            "links"
        },
        {
            "slug",
            "Title",
            "Course",
            "Concepts",
            "Exercises",
            "web",
            "icon",
            "tags",
            "last_touched_at",
            "isNew",
            "links"
        }
    )
in
    Languages

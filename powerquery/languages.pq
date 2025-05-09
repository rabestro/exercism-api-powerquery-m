/*
    
*/
let
    API_URL = "https://exercism.org/api/v2/tracks",
    Content = try Web.Contents(API_URL, [Timeout=#duration(0, 0, 30, 0)]) otherwise error "Failed to fetch data from API",
    JsonDoc = try Json.Document(Content) otherwise error "Invalid JSON response from API",
    Tracks = Table.FromList(JsonDoc[tracks], Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    Languages = Table.ExpandRecordColumn(
        Tracks,
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

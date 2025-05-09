/*
    This file contains a Power Query function to fetch exercises from the Exercism API.
    The function takes a track name as input and returns a table with exercise details.

    Usage:
    1. Load this file into Power Query.
    2. Call the function with the desired track name.
*/
(track as text) =>
    let
        API_URL = "https://exercism.org/api/v2/tracks/" & track & "/exercises",
        Content = Web.Contents(API_URL),
        JsonDoc = Json.Document(Content),
        ExerciseList = Table.FromList(JsonDoc[exercises], Splitter.SplitByNothing(), null, null, ExtraValues.Error),
        ExerciseEntries = Table.ExpandRecordColumn(
            ExerciseList,
            "Column1",
            {"slug", "type", "title", "difficulty", "blurb", "is_external", "is_unlocked", "is_recommended"},
            {"slug", "Type", "Title", "Difficulty", "Blurb", "IsExternal", "IsUnlocked", "IsRecommended"}
        ),
        Exercises = Table.TransformColumnTypes(
            ExerciseEntries,
            {
                {"IsRecommended", type logical},
                {"IsUnlocked", type logical},
                {"IsExternal", type logical},
                {"Blurb", type text},
                {"Difficulty", type text},
                {"slug", type text},
                {"Type", type text},
                {"Title", type text}
            }
        )
    in
        Exercises

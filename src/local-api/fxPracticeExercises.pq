/*
  Function: fxPracticeExercises

  Purpose:
    Retrieves a detailed list of practical exercises, including their names, slugs,
    UUIDs, difficulty, and status for a given language track by reading its
    'config.json' file.

  Parameters:
    rootPath (text): The absolute root path to the directory containing the language
                     track folders (each track folder should contain a 'config.json').
                     Example: "C:/Dev/ExercismTracks"
    trackSlug (text): The slug (identifier) for the language track.
                      Example: "javascript"

  Returns:
    table: A table containing details for each practice exercise, with columns:
           "slug", "name", "uuid", "difficulty", "status".

  Example Usage:
    let
      exerciseDetails = fxPracticeExercises("C:/MyDev/ExercismTracks", "javascript")
    in
      exerciseDetails

  Author: Jegors Čemisovs
*/
let
    PracticeExercises = (rootPath as text, trackSlug as text) as table =>
        let
            ExerciseConfigPath = rootPath & "/" & trackSlug & "/config.json",
            SourceJson = Json.Document(File.Contents(ExerciseConfigPath)),
            AllExercisesNode = SourceJson[exercises],
            PracticeExerciseList = AllExercisesNode[practice],
            PracticeExercisesRawTable = Table.FromList(
                PracticeExerciseList, Splitter.SplitByNothing(), null, null, ExtraValues.Error
            ),
            PracticeExercisesDetailTable = Table.ExpandRecordColumn(
                PracticeExercisesRawTable, "Column1", {"slug", "name", "uuid", "difficulty", "status"}
            )
        in
            PracticeExercisesDetailTable
in
    PracticeExercises

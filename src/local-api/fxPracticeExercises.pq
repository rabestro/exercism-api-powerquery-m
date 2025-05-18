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

  Assumptions:
    1. A 'config.json' file exists at the path: '<rootPath>/<trackSlug>/config.json'.
       The function will error if this file is not found.
    2. The 'rootPath' parameter does not end with a forward slash ('/'). If it does,
       the path to 'config.json' might contain '//'.
    3. The 'config.json' file has a specific JSON structure:
       - It's an object containing an "exercises" key.
       - The "exercises" object contains a "practice" key.
       - The "practice" key holds a list of records.
       - Each record in the "practice" list is expected to contain at least
         the fields: "slug", "name", "uuid", "difficulty", and "status".
       The function will error if this structure is not met (e.g., keys are missing
       or data types are unexpected).

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

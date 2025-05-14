/*
  Function: fxPracticeExercises

  Purpose:
    Retrieves a list of practical exercise names for a given language track.

  Parameters:
    rootPath (text): The absolute root path to the exercises repository.
    trackSlug (text): The slug for the language track.

  Returns:
    table: A single-column table with the column header "Name".

  Example Usage:
    let
      exercises = fxPracticeExercises("C:/MyDev/ExercismTracks", "javascript")
    in
      exercises

  Assumptions:
    - Exercises for a track are located in subfolders within:
      '<rootPath>/<trackSlug>/exercises/practice/'
    - Each subfolder within the 'practice' directory represents a single exercise,
      and its name is the exercise name.

  Author: Jegors Čemisovs
*/

let
  PracticeExercises = (rootPath as text, trackSlug as text) as table =>
    let
      ExerciseDirectoryPath = rootPath & "/" & trackSlug & "/exercises/practice",
      AllFilesAndFolders = Folder.Contents(ExerciseDirectoryPath),
      FilteredExerciseFolders = Table.SelectRows(AllFilesAndFolders, each[Attributes][Kind] = "Folder"),
      ResultExerciseNames = Table.SelectColumns(FilteredExerciseFolders, {"Name"})
    in
      ResultExerciseNames
in
  PracticeExercises

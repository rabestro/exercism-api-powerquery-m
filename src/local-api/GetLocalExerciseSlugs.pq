// Description: Lists all exercise slugs (directory names) from the locally cloned
//              'exercism/problem-specifications/exercises' directory.
// Parameters: None
// Returns:
//   A list of text values, where each value is an exercise slug.
// Depends on:
//   - 'ExercismReposRootPath' parameter: The root path to the directory containing cloned Exercism repositories.

() =>
    let
        ExercisesDirectoryPath = ExercismReposRootPath & "/problem-specifications/exercises/",
        DirectoryContents = Folder.Contents(ExercisesDirectoryPath),
        ExerciseFolders = Table.SelectRows(DirectoryContents, each [Attributes][Kind] = "Folder"),
        ExerciseSlugs = ExerciseFolders[Name]
    in
        ExerciseSlugs

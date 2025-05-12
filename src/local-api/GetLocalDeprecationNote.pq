// Function Name: GetLocalDeprecationNote
// Description: Checks for a '.deprecated' file for a given Exercism exercise slug
//              in the locally cloned 'exercism/problem-specifications' repository
//              and returns its content if found.
// Parameter:
//   exerciseSlug (text): The slug of the exercise (e.g., "accumulate").
// Returns:
//   A nullable text value: The content of the '.deprecated' file if it exists, otherwise null.
// Depends on:
//   - 'ExercismReposRootPath' parameter: The root path to the directory containing cloned Exercism repositories.
    (slug as text) =>
        let
            NotePath = ExercismReposRootPath & "/problem-specifications/exercises/" & slug & "/.deprecated",
            BinaryContent = try File.Contents(NotePath) otherwise null,
            Note = Text.FromBinary(BinaryContent, TextEncoding.Utf8)

        in
            Note

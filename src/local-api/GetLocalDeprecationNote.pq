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
(exerciseSlug as text) =>
    let
        // Default null in case of errors or file not found
        DefaultNote = null,
        // Construct the full path to the .deprecated file
        DeprecationFilePath =
            try
                let
                    RootPath = ExercismReposRootPath,
                    PathSeparator = if Text.Contains(RootPath, "\") then "\" else "/",
                    CleanRootPath =
                        if Text.EndsWith(RootPath, PathSeparator) then
                            Text.Start(RootPath, Text.Length(RootPath) - 1)
                        else
                            RootPath,
                    CombinedPath = CleanRootPath
                        & PathSeparator
                        & "problem-specifications"
                        & PathSeparator
                        & "exercises"
                        & PathSeparator
                        & Uri.EscapeDataString(exerciseSlug)
                        & PathSeparator
                        & ".deprecated"
                in
                    CombinedPath
                otherwise null,
        // If ExercismReposRootPath is not set or invalid
        DeprecationNote =
            if DeprecationFilePath = null then
                DefaultNote
                // Or you could return an error message string
            else
                try
                    let
                        FileContentBinary = File.Contents(DeprecationFilePath),
                        NoteText = Text.FromBinary(FileContentBinary, TextEncoding.Utf8)
                    in
                        NoteText
                    // If File.Contents fails (e.g., file not found)
                    otherwise DefaultNote
        // Return null if .deprecated file doesn't exist or can't be read
    in
        DeprecationNote

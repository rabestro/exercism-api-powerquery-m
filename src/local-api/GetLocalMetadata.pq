// Function Name: GetLocalMetadata
// Description: Fetches and parses the metadata.toml file for a given Exercism exercise slug
//              from a locally cloned 'exercism/problem-specifications' repository.
// Parameter:
//   exerciseSlug (text): The slug of the exercise (e.g., "hello-world", "accumulate").
// Returns:
//   A record containing: title, blurb, source, source_url, and error_message (if any).
// Depends on:
//   - 'ExercismReposRootPath' parameter: The root path to the directory containing cloned Exercism repositories.
(exerciseSlug as text) =>
    let
        // Default record structure, also used in case of errors
        DefaultMetadataRecord = [title = null, blurb = null, source = null, source_url = null, error_message = null],
        // Construct the full path to the metadata.toml file
        // Assumes 'ExercismReposRootPath' parameter is defined and points to the root of your Exercism clones.
        // And that 'problem-specifications' is a subdirectory within that root.
        MetadataFilePath = ExercismReposRootPath
            & "/problem-specifications/exercises/"
            & exerciseSlug
            & "/metadata.toml",
        FetchedMetadata =
            if MetadataFilePath = null then
                DefaultMetadataRecord & [error_message = "ExercismReposRootPath parameter is not set or is invalid."]
            else
                try
                    let
                        FileContentBinary = File.Contents(MetadataFilePath),
                        TextContent = Text.FromBinary(FileContentBinary, TextEncoding.Utf8),
                        Lines = Lines.FromText(TextContent),
                        // Inner helper to extract a value for a given key from TOML-like lines
                        GetValueFromLines = (textLines as list, keyName as text) as nullable text =>
                            let
                                LinePrefixPattern = keyName & " = """,
                                // e.g., blurb = "
                                MatchingLineList = List.Select(textLines, each Text.StartsWith(_, LinePrefixPattern)),
                                Value =
                                    if List.IsEmpty(MatchingLineList) then
                                        null
                                    else
                                        let
                                            FullLine = List.First(MatchingLineList),
                                            ValuePart = Text.Range(FullLine, Text.Length(LinePrefixPattern)),
                                            TrimmedValue =
                                                if Text.EndsWith(ValuePart, """") then
                                                    Text.Start(ValuePart, Text.Length(ValuePart) - 1)
                                                else
                                                    ValuePart,
                                            UnescapedValue = Text.Replace(
                                                Text.Replace(TrimmedValue, "\\""", """"), "\\\\", "\"
                                            )
                                        in
                                            UnescapedValue
                            in
                                Value,
                        ExtractedTitle = GetValueFromLines(Lines, "title"),
                        ExtractedBlurb = GetValueFromLines(Lines, "blurb"),
                        ExtractedSource = GetValueFromLines(Lines, "source"),
                        ExtractedSourceURL = GetValueFromLines(Lines, "source_url")
                    in
                        [
                            title = ExtractedTitle,
                            blurb = ExtractedBlurb,
                            source = ExtractedSource,
                            source_url = ExtractedSourceURL,
                            error_message = null
                            // No error if successful
                        ]
                    // If File.Contents fails (e.g., file not found) or parsing fails
                otherwise
                    DefaultMetadataRecord
                        & [
                            error_message = "Failed to read or parse local metadata.toml from: "
                                & MetadataFilePath
                                & ". Error: "
                                & Error.Message
                        ]
    in
        FetchedMetadata

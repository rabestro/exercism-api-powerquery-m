// Function Name: ExerciseMetadata
// Description: Fetches and parses the metadata.toml file for a given Exercism exercise slug
//              from the exercism/problem-specifications repository.
// Parameter:
//   exerciseSlug (text): The slug of the exercise (e.g., "hello-world", "accumulate").
// Returns:
//   A record containing: title, blurb, source, source_url, and error_message (if any).

(exerciseSlug as text) =>
let
    MetadataURL = "https://raw.githubusercontent.com/exercism/problem-specifications/main/exercises/" & Uri.EscapeDataString(exerciseSlug) & "/metadata.toml",
    // Default record structure, also used in case of errors
    DefaultMetadataRecord = [title = null, blurb = null, source = null, source_url = null, error_message = null],

    FetchedMetadata = try
        let
            WebContent = Web.Contents(MetadataURL, [
                Headers=[#"User-Agent"="PowerQuery-Exercism-Metadata-Fetcher"], // Good practice to set User-Agent
                Timeout=#duration(0,0,15,0) // 15-second timeout for individual file
            ]),
            TextContent = Text.FromBinary(WebContent, TextEncoding.UTF8),
            Lines = Lines.FromText(TextContent),

            // Inner helper to extract a value for a given key from TOML-like lines
            GetValueFromLines = (textLines as list, keyName as text) as nullable text =>
                let
                    LinePrefix = keyName & " = """,
                    MatchingLine = List.Select(textLines, each Text.StartsWith(_, LinePrefix)),
                    Value = if List.IsEmpty(MatchingLine) then
                                null
                            else
                                // Extract text between the first quote after "key = "" and the closing quote on that line
                                Text.BetweenDelimiters(List.First(MatchingLine), LinePrefix, """", 0, 0)
                in Value,

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
                error_message = null // No error if successful
            ]
    // If Web.Contents or parsing fails, return default record with an error message
    otherwise DefaultMetadataRecord & [error_message = "Failed to fetch or parse metadata from: " & MetadataURL & ". Error: " & Text.FromBinary(Error.Message, TextEncoding.UTF8) ] // Added Error.Message for more details
in
    FetchedMetadata

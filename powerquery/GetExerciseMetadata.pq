// Function Name: GetExerciseMetadata
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
                Headers=[#"User-Agent"="PowerQuery-ExercismClient/1.0 (+https://github.com/Rabestro/exercism-api-powerquery-m)"],
                Timeout=#duration(0,0,15,0) // 15-second timeout for individual file
            ]),
            TextContent = Text.FromBinary(WebContent, TextEncoding.Utf8),
            Lines = Lines.FromText(TextContent),

            // Inner helper to extract a value for a given key from TOML-like lines
            GetValueFromLines = (textLines as list, keyName as text) as nullable text =>
                let
                    LinePrefixPattern = keyName & " = """, // e.g., blurb = "
                    MatchingLineList = List.Select(textLines, each Text.StartsWith(_, LinePrefixPattern)),
                    Value = if List.IsEmpty(MatchingLineList) then
                                null
                            else
                                let
                                    FullLine = List.First(MatchingLineList),
                                    // Get the part of the string after 'keyName = "'
                                    ValuePart = Text.Range(FullLine, Text.Length(LinePrefixPattern)),
                                    // Check if this part ends with a quote. If so, remove it.
                                    // This assumes the string doesn't have trailing comments on the same line after the quote.
                                    TrimmedValue = if Text.EndsWith(ValuePart, """") then
                                                     Text.Start(ValuePart, Text.Length(ValuePart) - 1)
                                                 else
                                                     ValuePart, // Should not happen for valid simple TOML strings but good for robustness
                                    // Replace escaped quotes \" with " and escaped backslashes \\ with \
                                    // Order matters: unescape backslashes first if they could be part of other escapes (not an issue here)
                                    // For simple \" and \\, this order is fine.
                                    UnescapedValue = Text.Replace(Text.Replace(TrimmedValue, "\\""", """"), "\\\\", "\")
                                in
                                    UnescapedValue
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
    otherwise DefaultMetadataRecord & [error_message = "Failed to fetch or parse metadata from: " & MetadataURL & ". Error: " & Error.Message ] 
in
    FetchedMetadata
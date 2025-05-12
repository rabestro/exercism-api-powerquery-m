// Function Name: GetLocalMetadata
// Description: Fetches and parses the metadata.toml file for a given Exercism exercise slug
//              from a locally cloned 'exercism/problem-specifications' repository.
// Parameter:
//   slug (text): The slug of the exercise (e.g., "hello-world", "accumulate").
// Returns:
//   A record containing: title, blurb, source and source_url.
// Depends on:
//   - 'ExercismReposRootPath' parameter: The root path to the directory containing cloned Exercism repositories.
(slug as text) =>
    let
        Path = ExercismReposRootPath & "/problem-specifications/exercises/" & slug & "/metadata.toml",
        BinaryContent = try File.Contents(Path) otherwise null,
        TextContent = Text.FromBinary(BinaryContent, TextEncoding.Utf8),
        Lines = Lines.FromText(TextContent),
        NormText = List.Transform(Lines, each Text.Replace(_, "\""", """""")),
        Tuples = List.Transform(NormText, Splitter.SplitTextByAnyDelimiter({" = "}, QuoteStyle.Csv)),
        Records = List.Transform(Tuples, each Record.AddField([], _{0}, _{1})),
        Card = Record.Combine(Records)
    in
        Card

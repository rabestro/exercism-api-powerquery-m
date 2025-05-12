(slug as text) =>
    let
        ReposRoot = "/Users/jcemisovs/IdeaProjects/Exercism",
        ExercisesPath = ReposRoot & "/problem-specifications/exercises/",
        ExercisePath = ExercisesPath & slug,
        MetadataPath = ExercisePath & "/metadata.toml",
        BinaryContent = try File.Contents(MetadataPath) otherwise null,
        TextContent = Text.FromBinary(BinaryContent, TextEncoding.Utf8),
        Lines = Lines.FromText(TextContent),
        NormText = List.Transform(Lines, each Text.Replace(_, "\""", """""")),
        Tuples = List.Transform(NormText, Splitter.SplitTextByAnyDelimiter({" = "}, QuoteStyle.Csv)),
        Records = List.Transform(Tuples, each Record.AddField([], _{0}, _{1})),
        CoreData = Record.Combine(Records),
        DeprecatePath = ExercisePath & "/.deprecated",
        Note = try Text.FromBinary(File.Contents(DeprecatePath), TextEncoding.Utf8) otherwise null,
        Metadata = CoreData & [IsDeprecated = Note <> null, DeprecationNote = Note]   
    in
        Metadata
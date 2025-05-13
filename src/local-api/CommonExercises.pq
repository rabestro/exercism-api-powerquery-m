let
    ExercisesPath = ExercismRepositoryPath & "/problem-specifications/exercises/",
    DirectoryContents = Folder.Contents(ExercisesPath),
    ExerciseFolders = Table.SelectRows(DirectoryContents, each[Attributes][Kind] = "Folder"),
    ProcessedExerciseFolders = Table.AddColumn(
        ExerciseFolders,
        "metadata",
        each
            let
                MetaRow = Table.SelectRows([Content], each ([Name] = "metadata.toml")),
                DeprRow = Table.SelectRows([Content], each ([Name] = ".deprecated")),
                IsDeprecated = not Table.IsEmpty(DeprRow),
                DeprecationNote = if IsDeprecated then Text.FromBinary(DeprRow{0}[Content]) else null,
                MetaContent = MetaRow{[Name = "metadata.toml"]}[Content],
                MetaEntries = Csv.Document(MetaContent, {"Name", "Value"}, " = ", ExtraValues.Ignore),
                MetaData = Record.FromTable(MetaEntries)
            in
                MetaData & [deprecated = IsDeprecated, note = DeprecationNote]
    ),
    SelectedExerciseAndMetadata = Table.SelectColumns(ProcessedExerciseFolders, {"Name", "metadata"}),
    ExercisesTable = Table.ExpandRecordColumn(
        SelectedExerciseAndMetadata, "metadata", {"title", "blurb", "source", "source_url", "deprecated", "note"}
    )
in
    ExercisesTable

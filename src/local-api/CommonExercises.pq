let
    ExercisesPath = ExercismRepositoryPath & "/problem-specifications/exercises/",

    DirectoryContents = Folder.Contents(ExercisesPath),
    ExerciseFolders = Table.SelectRows(DirectoryContents, each[Attributes][Kind] = "Folder"),
    Exercises = Table.AddColumn(
        ExerciseFolders,
        "metadata",
        each
            let
                MetaRow = Table.SelectRows([Content], each ([Name] = "metadata.toml")),
                MetaContent = MetaRow{[Name = "metadata.toml"]}[Content],
                MetaEntries = Csv.Document(MetaContent, {"Name", "Value"}, " = ", ExtraValues.Ignore),
                MetaData = Record.FromTable(MetaEntries)
            in
                MetaData
    ),
    TwoColumns = Table.SelectColumns(Exercises, {"Name", "metadata"}),
    ExercisesTable = Table.ExpandRecordColumn(
        TwoColumns,
        "metadata",
        {"title", "blurb", "source", "source_url"}
    )
in
    ExercisesTable

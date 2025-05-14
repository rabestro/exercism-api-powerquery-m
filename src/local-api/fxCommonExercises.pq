/*
  Function: fxCommonExercises

  Purpose:
    Retrieves a table of common exercises and their associated metadata from a
    specified directory structure. It reads metadata from 'metadata.toml' files
    and checks for '.deprecated' files within each exercise's folder.

  Parameters:
    rootPath (text): The absolute root path to the directory containing
                    the 'problem-specifications/exercises/' structure.

  Returns:
    table: A table where each row represents an exercise, with columns for its
          name and extracted metadata fields: "title", "blurb", "source",
          "source_url", "deprecated" (boolean), and "note" (deprecation note).
*/

let
  CommonExercises = (rootPath as text) as table =>
    let
      ExerciseDirectoryPath = rootPath & "/problem-specifications/exercises/",
      AllFilesAndFolders = Folder.Contents(ExerciseDirectoryPath),
      FilteredExerciseFolders = Table.SelectRows(AllFilesAndFolders, each[Attributes][Kind] = "Folder"),

      ProcessedExerciseFolders = Table.AddColumn(
        FilteredExerciseFolders,
        "metadata",
        each
            let
                DeprecationFileRow = Table.SelectRows([Content], each ([Name] = ".deprecated")),
                IsDeprecated = not Table.IsEmpty(DeprecationFileRow),
                DeprecationNote = if IsDeprecated then Text.FromBinary(DeprecationFileRow{0}[Content]) else null,
                TomlBinaryContent = [Content]{[Name = "metadata.toml"]}[Content],
                MetaEntriesTable = Csv.Document(TomlBinaryContent, {"Name", "Value"}, " = ", ExtraValues.Ignore),
                MetadataRecord = Record.FromTable(MetaEntriesTable)
            in
                MetadataRecord & [deprecated = IsDeprecated, note = DeprecationNote]
    ),
    SelectedExerciseAndMetadata = Table.SelectColumns(ProcessedExerciseFolders, {"Name", "metadata"}),
    ExercisesDetailTable = Table.ExpandRecordColumn(
        SelectedExerciseAndMetadata, "metadata", {"title", "blurb", "source", "source_url", "deprecated", "note"}
    )
    in
      ExercisesDetailTable
in
  CommonExercises

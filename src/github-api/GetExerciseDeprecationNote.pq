// Function Name: GetExerciseDeprecationNote
// Description: Checks for a '.deprecated' file for a given Exercism exercise slug in the
//              exercism/problem-specifications repository using the GitHub Contents API
//              and returns its content if found.
// Parameter:
//   exerciseSlug (text): The slug of the exercise (e.g., "accumulate").
// Returns:
//   A nullable text value: The content of the '.deprecated' file if it exists, otherwise null.
// Depends on:
//   - (Optionally) 'GitHubAPIToken' parameter: Used for authenticated requests if defined.

(exerciseSlug as text) =>
let
    // Define the base URL for the GitHub Contents API
    BaseAPIURL = "https://api.github.com/repos/exercism/problem-specifications/contents/", // Base for contents
    // Define the relative path for the specific .deprecated file
    RelativeDeprecationFilePath = "exercises/" & Uri.EscapeDataString(exerciseSlug) & "/.deprecated",

    // Get standard GitHub API headers by calling the helper function
    RequestHeaders = GetGitHubApiHeaders(),

    // Attempt to fetch the file metadata and content using the GitHub Contents API
    DeprecationNote =
        let
            // Using a general try...otherwise for unexpected errors during the process.
            Result = try
                let
                    WebContentResponse = Web.Contents(BaseAPIURL, [
                        RelativePath = RelativeDeprecationFilePath,
                        Query = [ref = "main"], // Specify branch as a query parameter
                        Headers = RequestHeaders,
                        Timeout = #duration(0,0,15,0), // Timeout for API call
                        ManualStatusHandling = {404} // Explicitly handle 404 as non-fatal
                    ]),

                    // Check the type of WebContentResponse.
                    // If 404 (and handled by ManualStatusHandling), Web.Contents returns a record with response details.
                    // If 200 OK, Web.Contents returns the binary content directly.
                    NoteText =
                        if Value.Is(WebContentResponse, type record) and Record.FieldOrDefault(WebContentResponse, "Response.Status", 200) = 404 then
                            null // File not found (404), so not deprecated
                        else if Value.Is(WebContentResponse, type binary) then // Successful fetch (200 OK)
                            let
                                ApiResponseJson = Json.Document(WebContentResponse),
                                Base64Content = Text.Replace(Record.FieldOrDefault(ApiResponseJson, "content", ""), "#(lf)", ""),
                                DecodedBinary = if Base64Content <> "" then
                                                    Binary.FromText(Base64Content, BinaryEncoding.Base64)
                                                else
                                                    null,
                                ExtractedText = if DecodedBinary <> null then
                                                   Text.FromBinary(DecodedBinary, TextEncoding.Utf8)
                                               else
                                                   null
                            in
                                ExtractedText
                        else
                            // This case should ideally not be reached if ManualStatusHandling for 404 is working as expected
                            // and other errors are caught by the outer try.
                            // Could indicate an unhandled status code or unexpected response structure.
                            null
                in
                    NoteText
            otherwise
                null // Outer try: Catches any other errors (network, unexpected issues), return null
        in
            Result
in
    DeprecationNote

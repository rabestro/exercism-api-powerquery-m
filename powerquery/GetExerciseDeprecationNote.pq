// Function Name: GetExerciseDeprecationNote
// Description: Checks for a '.deprecated' file for a given Exercism exercise slug in the
//              exercism/problem-specifications repository and returns its content if found.
//              Optimized to reduce connection prompts and for robust 404 error handling.
// Parameter:
//   exerciseSlug (text): The slug of the exercise (e.g., "accumulate").
// Returns:
//   A nullable text value: The content of the '.deprecated' file if it exists, otherwise null.
// Depends on:
//   - (Optionally) 'GitHubAPIToken' parameter: Used for authenticated requests if defined.

(exerciseSlug as text) =>
    let
        exerciseSlug = "acronym",
        // Define the base URL for the raw content
        BaseURL = "https://raw.githubusercontent.com/exercism/problem-specifications/main/exercises/",
        // Define the relative path for the specific .deprecated file
        RelativeDeprecationFilePath = Uri.EscapeDataString(exerciseSlug) & "/.deprecated",

        // Define request headers, including the GitHub API Token if available
        RequestHeaders =
            let
                BaseHeaders = [#"User-Agent"="PowerQuery-ExercismClient/1.0 (+https://github.com/Rabestro/exercism-api-powerquery-m)"],
                TokenValue = try GitHubAPIToken otherwise null // Safely check for GitHubAPIToken parameter
            in
                if TokenValue <> null and TokenValue <> "" then
                    BaseHeaders & [#"Authorization"="token " & TokenValue] // Add Authorization if token exists
                else
                    BaseHeaders, // Only BaseHeaders if no token
        
        DeprecationNote = try
            let
                // Attempt to fetch the content of the .deprecated file
                // Using BaseURL and RelativePath to help Power Query manage data source privacy
                WebContent = Web.Contents(BaseURL, [
                    RelativePath = RelativeDeprecationFilePath, // Dynamic part of the URL
                    Headers = RequestHeaders,
                    Timeout = #duration(0,0,10,0), // Shorter timeout
                    ManualStatusHandling = {404} // Treat 404 Not Found as a non-error
                ]),
                TextResponse = Text.FromBinary(WebContent, TextEncoding.Utf8),
                isNotFound = Text.StartsWith(TextResponse, "404")
            in
                if isNotFound then null else TextResponse 
        otherwise
            null // Any other error during Web.Contents (e.g., network issue), treat as note not available
    in
        DeprecationNote
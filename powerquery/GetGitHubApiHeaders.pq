// Function Query Name: GetGitHubApiHeaders
// Description: This function constructs and returns a standard set of request headers
//              for making calls to the GitHub API. It includes the User-Agent,
//              the standard Accept header for API v3, and conditionally adds an
//              Authorization header if the 'GitHubAPIToken' parameter is set.
// Parameters: None
// Returns: A record containing the HTTP headers.
// Depends on:
//   - (Optionally) 'GitHubAPIToken' parameter: Used for authenticated requests if defined.
() =>
    let
        // Standard GitHub API Accept header + User-Agent
        InitialHeaders = [
            #"Accept" = "application/vnd.github.v3+json",
            #"User-Agent" = "PowerQuery-ExercismClient/1.0 (+https://github.com/Rabestro/exercism-api-powerquery-m)"
        ],
        TokenValue = try GitHubAPIToken otherwise null,
        // Safely check for GitHubAPIToken parameter
        RequestHeaders =
        // Start with InitialHeaders and conditionally add Authorization header
        if TokenValue <> null and TokenValue <> "" then
            InitialHeaders & [#"Authorization" = "token " & TokenValue]
        else
            InitialHeaders
    in
        RequestHeaders

// Description: This query defines a Power Query parameter for a GitHub Personal Access Token (PAT).
//              It allows other queries to securely and manageably access the GitHub API
//              by referencing this parameter.
//
// How to Use:
// 1. When this query is loaded into Power Query, it will appear as a parameter
//    (likely named 'GitHubAPIToken' based on the filename you intend to use for the query itself).
// 2. IMPORTANT: Replace the placeholder string "put your GitHub Token here" below
//    with your actual GitHub Personal Access Token.
// 3. Ensure your token has the necessary scopes/permissions for the API calls you intend to make.
// 4. Other M queries can then reference this parameter by its name (e.g., GitHubAPIToken)
//    to include the token in API request headers.
//
// Security Note:
// - Avoid committing your actual token to version control if this file is part of a public repository.
//   Each user should typically set their own token value locally in their Power Query environment.
// - The token will be stored within the Power BI PBIX file or Excel workbook if saved with a value.
//   Manage sharing of such files accordingly.

let
    // Current Value of the parameter.
    // Replace the placeholder string below with your actual GitHub PAT.
    Source = "put your GitHub Token here" meta [
        // Metadata defining this query as a parameter:
        IsParameterQuery = true,
        IsParameterQueryRequired = true,
        Type = "Text"
    ]
in
    Source

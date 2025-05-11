// Description: This query defines a Power Query parameter for an Exercism API Token.
//              It allows other queries that interact with the Exercism API
//              to use this token for authenticated requests.
//
// How to Obtain Your Exercism API Token:
// 1. Log in to Exercism.org.
// 2. Click the three-dot menu in the top right corner.
// 3. Select "Settings".
// 4. In the Settings menu, select "API / CLI Token".
// 5. Copy your token from there.
//
// How to Use This Parameter File:
// 1. When this query is loaded into Power Query, it will appear as a parameter
//    (e.g., named 'ExercismAPIToken' if you name the query itself that).
// 2. IMPORTANT: Replace the placeholder string "put your Exercism API Token here" below
//    with your actual Exercism API Token.
// 3. Other M queries designed to call the Exercism API can then reference this parameter
//    by its name (e.g., ExercismAPIToken) to include the token in API request headers
//
// Security Note:
// - Avoid committing your actual token to version control if this file is part of a public repository.
//   Each user should typically set their own token value locally in their Power Query environment.
// - The token will be stored within the Power BI PBIX file or Excel workbook if saved with a value.
//   Manage sharing of such files accordingly.
let
    // Current Value of the parameter.
    // Replace the placeholder string below with your actual Exercism API Token.
    Source = "put your Exercism API Token here" meta [
        // Metadata defining this query as a parameter:
        // Identifies this query as a parameter.
        IsParameterQuery = true,
        // Specifies that this parameter must have a value.
        // Set to false if the token is optional for some queries.
        IsParameterQueryRequired = true,
        // Defines the data type of the parameter as Text.
        Type = "Text"
    ]
in
    Source

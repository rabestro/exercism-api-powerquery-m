// File: ExercismReposRootPath.pq
// Description: This query defines a Power Query parameter for the local file system path
//              to a root directory where various Exercism repositories (e.g., 'problem-specifications',
//              track repositories like 'awk', 'bash') are cloned.
//              It allows other queries to access files from these local clones.
//
// How to Use:
// 1. Create a root directory on your local machine where you will clone Exercism repositories.
//    Example: mkdir ~/ExercismRepos
// 2. Clone the necessary Exercism repositories into this root directory. For example:
//    cd ~/ExercismRepos
//    git clone https://github.com/exercism/problem-specifications.git
//    git clone https://github.com/exercism/awk.git
//    (Clone any other repositories you need, like 'bash', 'java', etc.)
// 3. When this query is loaded into Power Query, it will appear as a parameter
//    (e.g., named 'ExercismReposRootPath' if you name the query itself that).
// 4. IMPORTANT: Replace the placeholder string "~/IdeaProjects/Exercism"
//    below with the actual absolute path to YOUR ROOT DIRECTORY containing your cloned Exercism repositories.
//    Examples:
//      - Windows: "C:\Users\YourUser\Documents\GitHub\MyExercismClones"
//      - macOS/Linux: "/Users/YourUser/Documents/ExercismRepos"
// 5. Other M queries designed to read from local clones will use this root path and then
//    append the specific repository name (e.g., "problem-specifications") and file path.
//
// Note:
// - Ensure the path is correct and that Power Query has the necessary permissions to access it.
// - Users of these local-file-based queries will need to manage updating their local clones
//   (e.g., using 'git pull' within each repository) to get the latest versions.
let
    // Replace the placeholder string below with the actual absolute path to your
    // root directory containing local clones of Exercism repositories.
    Source = "~/IdeaProjects/Exercism" meta [
        IsParameterQuery = true,            
        IsParameterQueryRequired = true,    
        Type = "Text"
    ]
in
    Source

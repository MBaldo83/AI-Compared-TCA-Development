## Setup 
You need to Add The Composable Architecture as a dependency see [Getting Started](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/gettingstarted)

## Prompts

### Attempt 1

```
I need you to write Swift code for a SwiftUI feature using The Composable Architecture (TCA) pattern - https://github.com/pointfreeco/swift-composable-architecture that includes:
* A TextField where the user can input a topic.
* A Button that, when tapped, triggers an action to load questions related to the entered topic.
* A List that displays all the questions fetched from a mock API based on the topic.
* A Loading Spinner (ActivityIndicator) that appears while the questions are being fetched.
* If no questions are found, the list should appear empty.

Use The Composable Architecture (TCA) structure, ensuring that the code is:
* Modular, clean, and testable.
* Built with the following components:
  * View: A SwiftUI view that displays the text field, button, list of questions, and loading spinner.
  * Feature: A Struct that contains the reducer logic, handles how actions modify the state, including setting loading state, handling results, and updating the view accordingly.
    * Within the Feature struct
       * State: Holds the user's topic input, the loading state, the fetched questions, and a flag for handling empty results.
       * Action: Triggers for text input changes, button taps, starting the API call, receiving the API response, and finishing loading.
  * APIClient: Simulates a simple API call using a delay. This should be a dependency that can be used by the Feature

Ensure that:
* If the API call returns no questions, display an empty list with no error message.
* While the API call is in progress, show a loading spinner in place of the list.
* You provide comments to explain each part of the architecture.
* The code is concise, avoiding unnecessary complexity.
* Do not include unit tests in the code. Return the complete code as a single file that can be copied directly and run in an existing XCode project
```

---- RESULT - Claude Sonnet 3.5

-- Output
Single File
Compiled Immediately? - NO
* Build Errors - 6
Compiled after tweaks - No

---- RESULT - ChatGPT 4o

-- Output
Single File
Compiled Immediately? - NO
* Build Errors - 13
Compiled after tweaks - No

### Attempt 2

Prompt: Same as before

-- Output
Single File
Compiled Immediately? - Yes
* Build Errors - 0

## Setup

Tools used:
- Cursor AI Version: 0.41.2
  - LLM: claude-3.5-sonnet
- VSCode Version: 1.91.1
- Xcode 15.4
- iOS 17.5

Time taken to complete app: 
Number of build errors during process: 
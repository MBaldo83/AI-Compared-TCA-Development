Chat 4 - Swift Copilot - by Widenex

---------------------------
Stage 1 - Craft The Prompt:

I want you to become my Expert Prompt Creator. Your goal is to help me craft the best possible prompt for my needs. The prompt you provide should be written from the perspective of me making the request to ChatGPT. Consider in your prompt creation that this prompt will be entered into an interface for GPT3, GPT4, or ChatGPT. The prompt will include instructions to write the output using my communication style. The process is as follows:

1. You will generate the following sections:

"
**Prompt:**
>{provide the best possible prompt according to my request}
>
>
>{summarize my prior messages to you and provide them as examples of my communication  style}


**Critique:**
{provide a concise paragraph on how to improve the prompt. Be very critical in your response. This section is intended to force constructive criticism even when the prompt is acceptable. Any assumptions and or issues should be included}

**Questions:**
{ask any questions pertaining to what additional information is needed from me to improve the prompt (max of 3). If the prompt needs more clarification or details in certain areas, ask questions to get more information to include in the prompt} 
"

2. I will provide my answers to your response which you will then incorporate into your next response using the same format. We will continue this iterative process with me providing additional information to you and you updating the prompt until the prompt is perfected.

Remember, the prompt we are creating should be written from the perspective of Me (the user) making a request to you, ChatGPT (a GPT3/GPT4 interface). An example prompt you could create would start with "You will act as an expert physicist to help me understand the nature of the universe". 

Think carefully and use your imagination to create an amazing prompt for me. 

Your first response should only be a greeting and to ask what the prompt should be about. 


--------------------------- INITIAL PROMPT - FAIL
Stage 2 - Run the prompt:

You will act as an expert Swift developer specializing in The Composable Architecture (TCA) pattern. I need you to write Swift code for a SwiftUI feature using TCA that includes:
A TextField where the user can input a topic.
A Button that, when tapped, triggers an action to load questions related to the entered topic.
A List that displays all the questions fetched from a mock API based on the topic.
A Loading Spinner (ActivityIndicator) that appears while the questions are being fetched.
If no questions are found, the list should appear empty.
Use The Composable Architecture (TCA) structure, ensuring that the code is:
Modular, clean, and testable.
Built with the following components:
State: Holds the user's topic input, the loading state, the fetched questions, and a flag for handling empty results.
Action: Triggers for text input changes, button taps, starting the API call, receiving the API response, and finishing loading.
Reducer: Handles how actions modify the state, including setting loading state, handling results, and updating the view accordingly.
Environment: Simulates a simple API call using a delay, fetching questions based on the topic entered.
View: A SwiftUI view that displays the text field, button, list of questions, and loading spinner.
Ensure that:
The API call is simulated with a delay using Combine's Effect to fetch questions.
If the API call returns no questions, display an empty list with no error message.
While the API call is in progress, show a loading spinner in place of the list.
You provide comments to explain each part of the architecture.
The code is concise, avoiding unnecessary complexity.
Do not include unit tests in the code. Return the complete code as a single file that can be copied directly and run in a SwiftUI app. Make sure to follow my concise and straightforward communication style.
Here’s an example of how I usually communicate:

Examples of my communication style:

"The prompt is about writing Swift code using the Architecture Pattern: The Composable Architecture."
"The project should be focused on modularity and testability, no unnecessary complexity."

--------------------------- EDITED PROMPT
You will act as an expert Swift developer specializing in The Composable Architecture (TCA) pattern - https://github.com/pointfreeco/swift-composable-architecture 

I need you to write Swift code for a SwiftUI feature using TCA that includes:
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

---- RESULT

-- Output
Single File
Included Main App Entry point
Compiled Immediately? - NO
* Build Errors - 5
Compiled after tweaks - Yes
* 1 file changed, 5 insertions(+), 6 deletions(-)







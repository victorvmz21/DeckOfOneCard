#  Deck of One Card

DeckOfOneCard is a simple, one-button app that draws a card at random by fetching it from an online server.
Though the interface is simple, students will be introduced to a handful of new concepts under the hood; including HTTP Requests, JSON decoding, closures and concurrency.

## Part Zero - Familiarity with the Documentation

* Find which endpoint to hit
* Look at a sample response (JSON)
* Based off the JSON, determine how to structure your model

All data/images presented in the DeckOfOneCard app are retrieved from deckofcardsapi.com. In other words, your app is the front end and the server is the back end.

Because your app depends on continuous communication with the server, it's important to understand two things.
- How to talk to the server (which endpoint to hit).
- How to decode the response (the JSON).

1. Go to **http://deckofcardsapi.com** and look at the different endpoints available. You want to hit the "Draw a Card" endpoint. Modify the sample URL they provide so that it requests a "new" deck each time with a card count of 1. `https://deckofcardsapi.com/api/deck/new/draw/?count=1`
2. Paste your new url into a web browser and you should get some JSON. 
3. On its own, unformatted JSON can be hard to read. Copy and paste it into an online JSON viewer. One can be found at **http://jsonviewer.stack.hu**.
4. The top level dictionary should contain an array named "cards". Look at the dictionary at index 0 in the array. It should have fields for "value", "suit" and "image". That is your model, the Card you want to draw each time a button is tapped.

## Part One - Storyboard and Model

### Storyboard

* Go to `Main.storyboard`, drag out a `UIImageView` and center it horizontally and vertically in the view controller.
* Constrain a `UILabel` horizontally centered directly above the image view. This label will hold both the `value` and `suit` of each drawn card.
* Lastly, center a `UIButton` at the bottom of the screen and title it "Draw".

### Model

* Create a new file named `Card.swift` and declare a new struct `Card` that conforms to `Decodable`.

> Your app is a visual representation of the JSON so your model has to be structured accordingly.

* Add properties to your struct based off of the JSON you will be receiving. `String` properties named "value" and "suit" and a `URL` named "image".

> We've identified your Card model in the JSON, but it's embedded a few levels deep.
You'll have to model out the rest of the JSON structure in Swift so that it can decode all the way down to the Card.

* One the same file, declare a new struct `TopLevelObject` which also conforms to `Decodable`.

> The JSON has an array named "cards" so you need to do the same in Swift.

* Give your new struct a single property `cards: [Card]`. You have now modeled out the entire JSON structure and are ready to request live data from the server.

## Part Two - Card Controller and Custom Error

### CardController - Fetch Card

* Create a new Swift file and class named `CardController`.

> You won't be holding any Card objects on the CardController, so you won't need a singleton.

* Declare a static function to fetch a card from the server. It will take in a single argument, a completion block `(Result <Card, CardError>) -> Void`
```
static func fetchCard(completion: @escaping (Result <Card, CardError>) -> Void) {
    // 1 - Prepare URL
    
    // 2 - Contact server
    
    // 3 - Handle errors from the server
    
    // 4 - Check for json data
    
    // 5 - Decode json into a Card
}
```
* The compiler will complain about the nonexistent error type. Create a new Swift file and enum named `CardError` that conforms to `LocalizedError`.
We will use this type to tell the user what went wrong in the event we fail to produce a Card from the server.

* In `fetchCard(completion:)`, use a guard statement to initialize a new `URL(string:)` and pass in the endpoint you determined during "Part Zero".

* Add a new case `invalidURL` to your CardError enum.

* For the `else` portion of your guard statement, make sure to call the completion (failure) and then pass in the reason why.
`else { return(completion(.failure(.invalidURL))) }`

* Next, call `URLSession.shared.dataTast(with:completion:)` and pass in the `URL` you unwrapped.
Name the completion arguments `data, _, error`.
```
URLSession.shared.dataTask(with: url) { data, _, error in 

    // 3 - Handle errors from the server
   
    // 4 - Check for json data
   
    // 5 - Decode json into a Card
}
```
* Use an if statement to unwrap the potential error. You need to add a new case to `CardError` that allows the passage of Apple's error: `case thrownError(Error)`. In your if statement, print the error and then call completion (failure). `return completion(.failure(.thrownError(unwrappedError)))`

* Use a guard statement to unwrap the data. In the `else` statement, complete (failure) with case `.noData`.

* Open up a `do` -  `catch` block where you will decode the received data.

* In the `do` portion, use a `JSONDecoder` to decode a `TopLevelObject`. It's a throwing function, so it has to be marked with `try`.
`let topLevelObject = try JSONDecoder().decode(TopLevelObject.self, from: data)`

* Unwrap the first card on your topLevelObject's array. If the unwrap fails, complete (failure) with `.noData`.

* If the unwrap is successful, complete successfully with the card. `return completion(.success(card))`

* Remember to print the error and complete (failure) in the `catch` portion.

* Call `.resume()` on your data task to finish off the `fetchCard(completion:)` function.

### CardController - Fetch Image

* Declare a static function that takes in a Card and completion block of type `(Result <UIImage, CardError>) -> Void`.
```
static func fetchImage(for card: Card, completion: @escaping (Result <UIImage, CardError>) -> Void) {

    // 1 - Prepare URL
    
    // 2 - Contact server
    
    // 3 - Handle errors from the server
    
    // 4 - Check for image data
    
    // 5 - Initialize an image from the data
}
```

* Just as before, you need a `URL` to contact the server at. This time you will pull it off of the card that is passed in.

* Declare another `dataTask` and pass in the url. Give the same argument names as before. `data, _, error`.

* Use an if statement to handle the error and call completion (failure) `.thrownError(error)` in the event of an error.

* Guard unwrap the data and call completion (failure) `.noData` if it's `nil`.

* Initialize a `UIImage` from the data using a guard statement and complete with `.unableToDecode` if it fails.
`guard let image = UIImage(data: data) else { return completion(.failure(.unableToDecode)) }`

* If it succeeds, complete with the image. Don't forget to call `.resume()` on your data task.

### CardError

* Each case on your custom error type should come with a description. It should clearly and simply explain to the user what went wrong or how to troubleshoot.

* In CardError, create a computed property `var errorDescription: String? {`.

* Within the block, write a switch statement, `switch self {`, that returns a unique `String` description for each case.
The finished product should look something like this:
```
enum CardError: LocalizedError {
    case invalidURL
    case thrownError(Error)
    case noData
    case unableToDecode
    
    // Give the user whatever information you think they should know. Feel free to write your own descriptions.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Internal error. Please update Deck of One Card or contact support."
        case .thrownError(let error):
            return error.localizedDescription
        case .noData:
            return "The server responded with no data."
        case .unableToDecode:
            return "The server responded with bad data."
        }
    }
}
```

## Part Three - Custom Error Alert and CardViewController

### Custom Error Alert

* Create a new Swift file called `UIViewControllerExtension`.

* Import `UIKit` and extend `UIViewController`.

* Create a function that takes in a `LocalizedError` and presents a `UIAlertController` with the error's `errorDescription`.

```
extension UIViewController {
    
    func presentErrorToUser(localizedError: LocalizedError) {
        
        // Feel free to customize the alert controller.
        let alertController = UIAlertController(title: "Error", message: localizedError.errorDescription, preferredStyle: .actionSheet)
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
}
```

* Because this function exists on the `UIViewController` class itself, you will be able to call it from any view controller in an app. Consider saving your extension as a code snippet for quick access in future projects.

### CardViewController

* Create a new Cocoa Touch class called `CardViewController`.

* Subclass the view controller on your storyboard and connect outlets for the image and label.

* Create an action for the draw button.

* Whenever the user taps the draw button, they expect a new card to appear. Inside of your action, call `CardController.fetchCard(completion:)`, press "return" and name the argument `result`.

* Remember that our completion handler is an `escaping` closure, so we need to create a capture list `[weak self]` to avoid memory leaks.
```
@IBAction func drawButtonTapped(_ sender: UIButton) {
    
    CardController.fetchCard { [weak self] (result) in
    
    }
}
```

* Each request has two possible "results". Either success or failure.
Inside the fetch completion, write a `switch` statement on `result` which covers both cases.
```
switch result {
    case .success(let card):

    case .failure(let error):
}
```

* For failure, call the function from your extension, `self?.presentErrorToUser(localizedError: error)`.

* You still need to fetch the card's image before you can update the interface.
Create a new function `func fetchImageAndUpdateViews(for card: Card)` and call it in the success case.

* Inside of the new function, fetch the image from your card controller.

* Create another `switch` statement on `result` with both cases. This time the success is an image.
```
func fetchImageAndUpdateViews(for card: Card) {

    CardController.fetchImage(for: card) { [weak self] result in
    
    switch result {
        case .success(let image):
    
        case .failure(let error):
    
        }
    }
}
```
* Present the error if there is one, otherwise, update the label with the card's suit and value `"\(card.value) of \(card.suit)"`

* Update the image view with the image.

* If you were to run the app right now, it would crash after you pushed the draw button. Whenever updating the UI after a fetch, you must return to the main thread.

* Wrap the switch statements in both of your fetch function inside of an `async` block.
```
DispatchQueue.main.async {
    switch result {
        // etc
    }
}
```
# DecoOfOneCard
# DeckOfOneCard

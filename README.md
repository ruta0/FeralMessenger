# This is a chat app with Swift 3+, Parse Server & MongoDB
<img src="https://raw.githubusercontent.com/jinhedev/FeralMessenger/master/art/1.jpg" width="200px" height="360px" /><img src="https://raw.githubusercontent.com/jinhedev/FeralMessenger/master/art/2.jpg" width="200px" height="360px" /><img src="https://raw.githubusercontent.com/jinhedev/FeralMessenger/master/art/3.jpg" width="200px" height="360px" />

## What's inside?
* OAuth for user login signup
* Keychain protection for user sensitive information
* Core Data persistence for download / upload efficiency
* Send and receive text messages with anyone inside the same database
* Size class support for all iOS devices and all screen orientations
* Push notification
* Some hidden secrets as bonus

## Requirements
* iOS 10+
* Xcode 8+
* Swift 3+

## Dependency
* Parse

## Bonus Secret?
> 404 secrets not found

## Instructions
1. | Signup for an account
2. | Login with your new account
3. | Chat with anyone in your database

## Class Structure

* To incorporate with Core Data and all of super methods, I needed a structure that is clean and re-usable for API calls from/to Parse and Core Data itself. So here what I did to improve the readability and resuability of the app's MVCs.
* As for classes that are not related to Core Data in any way, I haven't figured out a way to refactor them yet. The challenge is that they generally have a lot of custom parts, such as buttons and logo and stackviews.
<img src="https://raw.githubusercontent.com/jinhedev/FeralMessenger/master/art/structure.png" width="720px" height="480px" />

## Task List
- [x] Chat app of 2 MVCs with Parse Server pod
- [x] Size class support on all iOS device
- [x] Implement Core Data for persistency
- [x] Derive and refactor "Controller classes" to tripple inheritance structure
- [ ] Add sound files to outlet actions
- [ ] Push notification and emoji support
- [ ] Add a new Tab to allow user to manage their profile
- [ ] ...Automate custom database creation with Heroku

## Explanation in my blog
Visit [Initial Setup with CoreDataStack](https://sheltered-ridge-89457.herokuapp.com/posts/initial-setup-with-coredatastack) for details

## Support or Contact
Visit [ShelteredRidge](http://sheltered-ridge-89457.herokuapp.com/) to see all of my blog posts (well, 3 at least...)

## Licensing
My Feral project are licensed under [the MIT License](LICENSE)

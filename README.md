# HomeBite (SwiftUI)

HomeBite is an iOS SwiftUI app for university students to share, buy, or sell home-cooked meals.

## Features

- Onboarding: sign up/login, university, dietary and cuisine preferences
- Role selection: Customer, Cook, Seller
- Role-based tabs: Finder (map/list), Schedule, My Kitchen, Profile
- Finder: filters, dish cards, schedule pickup, booking sheet
- Dish Detail: description, ingredients, AI-editable tags
- My Kitchen: manage dishes and add new dish (photo placeholder)
- Profile: user info, roles, ratings, edit and logout
- APIService: async REST template (replace baseURL)

## Project Structure

- Models/: Codable models (User, Dish, Order, Rating) + MockData
- Services/: APIService
- ViewModels/: Minimal MVVM for each screen
- Views/: SwiftUI screens and shared components

## Run

Open `HomeBite.xcodeproj` in Xcode 15+, and build/run on iOS 17+ simulator.
The app entry `HomeBiteApp` now loads `HomeBiteRootView`.

If you want the app name on the Home Screen to show "HomeBite", set Bundle Display Name in Info.plist accordingly.

## Backend

`APIService` contains simple `get` and `post` helpers. Replace `baseURL` with your FastAPI or NestJS deployment and wire endpoints into ViewModels.

## Notes

- Image uploads are placeholders (no real picker yet).
- AI tag suggestions are simulated and fully editable.
- Map uses mock coordinates near Apple Park for demo.

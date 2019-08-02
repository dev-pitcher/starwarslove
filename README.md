# starwarslove

Star Wars Dating App

Requirements:

- retrieve a list of individuals from a REST web service
- store retrieved individuals in a local database
- display individuals profile pics in a table view
- display a detailed view of the individuals profile when a cell in the table view is tapped
- be creative in your solution

Design Decisions:

I decided to make a Star Wars dating app. The app retrieves the indivuals (as potential mates) from the web service and stores that info locally in a SQLite dabase. I use that stored info to show a list of "potential mates" in the table view and to create a bio including age, zodiac, etc. in the details view.

My approarch with 3rd party frameworks is typically not to bring in dependencies unless it's really worth the added bloat and complexity. With the frameworks I did use, my goal was to use frameworks built in Swift (or at least having a Swift interface) to avoid bringing in the bridging header if possible, just to keeps things cleaner and simpler.

For such a small amount of network activity my initial plan was to use URLSession but since I knew I'd also be displaying network images I decided to include a framework that simplifies downloading, displaying, and caching network images. I added Alamofire and AlamofireImages for that purpose and used Alamofire to access the web service as well.

I didn't want to mess with SQLite's C API so I searched for a good wrapper. I've used FMDB in the past but didn't want to bring in Objective C if possible so I researched a few swift SQLite wrappers on GitHub and ultimately picked the one with the most stars (SQLite.swift). One nice feature I liked in SQLite.swift is that you can insert a single Codable object as a row in the database, rather then specifying each column and value to be inserted. This allowed me to used the same objects (see PotentialMate class) both when encoding/decoding from JSON and as inputs/outputs to the database.

The datavflow of the app is:

- retrieve individuals from the web service at app startup
- in the meantime displays are updating using anything stored in the database
- when the web service query returns the new content is loaded into the database and the display is refreshed by again loading from the database



# SpotifyMe

SpotifyMe is a mobile application for Android designed to provide a personalized and distinctive experience for music exploration and discovery.

The platform incorporates a **user authentication system** that ensures exclusive access to registered accounts via **email and password**, securely managed through **Firebase Authentication**.

The app allows new user registration, login with registered credentials, as well as password recovery through an automated process that sends an email to reset the access password (functionality currently under development).

<div style="display: flex; justify-content: space-between;">
    <img src="https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/assetsReadme/login.jpg?raw=true" alt="login" style="width: 45%;">
    <img src="https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/assetsReadme/crearCuenta.jpg?raw=true" alt="create account" style="width: 45%;">
</div>

SpotifyMe integrates with the official Spotify API to provide up-to-date information about artists, albums, songs, and recent releases. Additionally, it enables music playback by redirecting directly to the official Spotify app, ensuring a smooth and familiar user experience.

The application consists of five main screens, each designed to optimize user interaction with musical content:

### Home Screen

This screen is organized into three main sections:

* **Discover New Artists**: Displays a gallery of 50 featured artists, showing their name and image. When selecting any artist, the user is redirected to their profile within the official Spotify app.

* **New Releases**: Shows the latest musical releases objectively, without algorithmic personalization.

* **Explore by Genre**: Offers buttons for different musical genres such as *pop*, *rock*, and *reggaeton*. Selecting a genre displays specific recommendations.

<div style="display: flex; justify-content: space-between;">
    <img src="https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/assetsReadme/inicio1.jpg?raw=true" alt="Home Screen - Section 1" style="width: 45%;">
    <img src="https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/assetsReadme/inicio2.jpg?raw=true" alt="Home Screen - Section 2" style="width: 45%;">
</div>

### Search Screen

This interface allows the user to search for artists and view their complete profile, which includes:

* Artist image
* Popularity level
* Number of followers
* Artist type
* Musical genre

Selecting an artist automatically plays the first song from their most recent album. Below the profile, scrollable lists display:

* Artist's albums (each allows playing its first song upon selection)
* Artist's most popular songs

Additionally, each song and album includes a heart-shaped button that allows saving the content to the Favorites section for quick and personalized access.

<div style="display: flex; justify-content: space-between;">
    <img src="https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/assetsReadme/buscador1.jpg?raw=true" alt="Search Screen - Artist Profile" style="width: 45%;">
    <img src="https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/assetsReadme/buscador2.jpg?raw=true" alt="Search Screen - Albums and Songs List" style="width: 45%;">
</div>

### Discover and Favorites Screen

* **Discover**: Displays a random song with relevant information such as image, name, popularity, and artist. Includes two buttons:

  * *Listen*: Plays a snippet of the song.
  * *Random*: Generates and displays a new different song.

* **Favorites**: Shows a list of songs and albums saved by the user, presenting the image, artist, and content type. It also allows deleting items from the list based on user preference.

<div style="display: flex; justify-content: space-between;">
    <img src="https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/assetsReadme/descubre.jpg?raw=true" alt="Discover Screen" style="width: 45%;">
    <img src="https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/assetsReadme/fav.jpg?raw=true" alt="Favorites Screen" style="width: 45%;">
</div>

### User Profile

This section displays the authenticated user's information:

* Profile image (or initial of the name if no image has been uploaded)
* Full name
* Email address

Additionally, it features a **Log Out** button that redirects the user to the login screen.

<div style="display: flex; justify-content: space-between;">
    <img src="https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/assetsReadme/perfil.jpg?raw=true" alt="User Profile" style="width: 45%;">
</div>

## Features to Implement

- [  ] Enable the password recovery email to allow users to actually reset their password, not just receive an informational email.


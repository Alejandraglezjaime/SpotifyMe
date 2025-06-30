# SpotifyMe

SpotifyMe es una aplicación móvil creada para ofrecer una experiencia diferente y personalizada al momento de descubrir nueva música.

La aplicación cuenta con un sistema de *autenticación de usuarios* que restringe el acceso únicamente a cuentas registradas mediante *correo electrónico y contraseña*, gestionadas de forma segura a través de *Firebase*.

SpotifyMe utiliza la API de Spotify para obtener información actualizada sobre artistas, canciones y lanzamientos recientes, además de permitir la reproducción de música redirigiendo directamente a la aplicación oficial de Spotify.

## Interfaces principales

La aplicación se compone de cuatro interfaces principales, cada una diseñada para mejorar la experiencia del usuario al interactuar con la música:

### Pantalla de Inicio

Dividida en tres secciones clave:

* **Descubre nuevos artistas**: Muestra una galería de 50 artistas con su nombre e imagen. Al seleccionar uno, se redirige a su perfil dentro de la app de Spotify.

* **Nuevos lanzamientos**: Presenta los estrenos musicales más recientes de manera objetiva, sin depender del algoritmo personalizado de Spotify.

* **Explorar por género**: Ofrece botones de géneros como *pop, rock, reguetón*, entre otros. Al seleccionar uno, se muestran recomendaciones musicales correspondientes.

![img inicio](https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/Img_git/inicio.jpg?raw=true)
![img inicio](https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/Img_git/inicio2.jpg?raw=true)

### Pantalla de Búsqueda

El usuario puede buscar un artista y visualizar su ficha bibliografica, que incluye:

* Imagen
* Popularidad
* Seguidores
* Tipo de artista
* Género

Al seleccionar el artista, se reproduce automáticamente la primera canción de su álbum más reciente. 

Debajo de la ficha bibliografica, se muestran en forma de lista deslizable:

* Sus álbumes (cada uno reproduce su primera canción al seleccionarlo)
* Sus canciones más escuchadas


![img inicio](https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/Img_git/buscador.jpg?raw=true)
![img inicio](https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/Img_git/buscador2.jpg?raw=true)

###  Pantalla Descubre

Muestra una canción aleatoria con su:

* Imagen
* Nombre
* Popularidad
* Artista

Incluye dos botones:

* Escuchar: Reproduce un fragmento de la canción.
* Aleatorio: Filtra y muestra una nueva canción diferente.

![img inicio](https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/Img_git/descubre.jpg?raw=true)

###  Perfil de Usuario

Muestra los datos del usuario autenticado:

* Imagen de perfil (o inicial del nombre si no se ha cargado una imagen)
* Nombre
* Correo electrónico

Incluye un botón de **Cerrar sesión**, que redirige al usuario a la pantalla de inicio de sesión.

![img inicio](https://github.com/Alejandraglezjaime/SpotifyMe/blob/main/Img_git/perfil.jpg?raw=true)

## Funcionalidades por implementar

* [ ] Permitir la creación de nuevas cuentas directamente desde la app.
* [ ] Permitir que el usuario agregue una imagen de perfil.
* [ ] Incorporar mayor personalización e interactividad en la experiencia del usuario dentro de la app.

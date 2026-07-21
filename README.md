<header id="readme-top">
  <div align="center">
    <img src="https://placehold.co/640x640/000000/FFFFFF?font=Open%20Sans&text=Komiku" alt="Logo" width="80" height="80">
    <h1>Komiku*</h1>
    <p><i>*The name is used solely as a project identifier. Any resemblance to existing names, trademarks, brands, or copyrighted works is unintentional. All rights remain with their respective owners.</i></p>
    <p>An app to read comic.</p>
    <p>
      Komiku is a mobile application designed for comic enthusiasts to browse, read, and interact with their favorite comics.
    </p>
    <a href="#installation">Installation</a>
    &middot;
    <a href="#commands">Commands</a>
    &middot;
    <a href="#demo">Demo</a>
    &middot;
    <a href="#api">API</a>
    <br><br>
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Badge" />
    <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart Badge" />
    <img src="https://img.shields.io/badge/Material_Design-757575?style=for-the-badge&logo=materialdesign&logoColor=white" alt="Material Design Badge" />
    <img src="https://img.shields.io/badge/Provider-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Provider Badge" />
    <img src="https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white" alt="PHP Badge" />
    <img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL Badge" />
    <img src="https://img.shields.io/badge/JWT-000000?style=for-the-badge&logo=jsonwebtokens&logoColor=white" alt="JWT Badge" />
    <img src="https://img.shields.io/badge/Shared_Preferences-4285F4?style=for-the-badge&logo=google&logoColor=white" alt="Shared Preferences Badge" />
    <img src="https://img.shields.io/badge/Apache-D22128?style=for-the-badge&logo=apache&logoColor=white" alt="Apache Badge" />
    <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker Badge" />
    <img src="https://img.shields.io/badge/Insomnia-4000BF?style=for-the-badge&logo=insomnia&logoColor=white" alt="Insomnia Badge" />
  </div>
</header>

<hr>

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#overview">Overview</a></li>
    <li><a href="#structure">Structure</a></li>
    <li><a href="#prerequisites">Prerequisites</a></li>
    <li><a href="#installation">Installation</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#commands">Commands</a></li>
    <li><a href="#demo">Demo</a></li>
    <li><a href="#api">API</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<section id="overview">
  <header>
    <h2>Overview</h2>
  </header>
  <p>
    Komiku is a feature-rich comic reading application that provides a seamless experience for users to discover and enjoy comics. It includes functionalities such as user registration, comic categorization, chapter-based reading, and a community interaction system through comments and ratings.
  </p>
  <p>
    The project is built using Flutter for the mobile app and a PHP-based backend, demonstrating a full-stack integration with state management and real-time data fetching.
  </p>
  <p align="right"><a href="#readme-top">Back to top</a></p>
</section>

<br>

<a id="structure"></a>

## Structure

<pre><code>komiku/
├── lib/
│   ├── components/        # Reusable UI widgets
│   ├── models/            # Data models
│   ├── screens/           # App screens
│   ├── provider/          # State management providers
│   ├── services/          # API services
│   ├── static/            # Static constants
│   ├── style/             # Theme and styling
│   └── main.dart          # Entry point
├── assets/                # Images and fonts
├── server/                # PHP Backend
│   ├── database/          # Database migrations and seeds
│   └── endpoint/          # API endpoints
└── README.md</code></pre>
<p>
  The project follows a modular Flutter directory structure, separating UI components, 
  business logic, and data models to maintain a clean and scalable codebase.
</p>
<p align="right"><a href="#readme-top">Back to top</a></p>

<br>

<section id="prerequisites">
 <header>
    <h2>Prerequisites</h2>
  </header>
  <table>
    <thead>
      <tr>
        <th>Component</th>
        <th>Requirements</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><strong>Flutter Application</strong></td>
        <td>
          <ul>
            <li>Flutter SDK (latest stable version)</li>
            <li>Dart SDK</li>
            <li>Android Studio or VS Code with Flutter extension</li>
            <li>Android Emulator or a physical device</li>
          </ul>
        </td>
      </tr>
      <tr>
        <td><strong>Backend API</strong></td>
        <td>
          <ul>
            <li>Docker Desktop</li>
            <li>Docker Compose</li>
            <li>Git (recommended)</li>
          </ul>
        </td>
      </tr>
    </tbody>
  </table>
  <p align="right"><a href="#readme-top">Back to top</a></p>
</section>

<br>

<a id="installation"></a>

## Installation

This project consists of two main components:

- **Flutter Mobile Application**
- **PHP REST API (Dockerized)**

---

### Flutter Application

1. Clone the repository.

```sh
git clone <REPOSITORY_URL>
cd Komiku
```

2. Navigate to the Flutter project.

```sh
cd komiku
```

3. Install dependencies.

```sh
flutter pub get
```

4. Configure the API endpoint.

Update the base URL inside the API configuration to point to your backend.

Example:

```dart
const String baseUrl = "http://localhost:8080";
```

5. Run the application.

```sh
flutter run
```

---

### Backend API (Docker)

The backend API is fully containerized using Docker and Docker Compose.

#### Prerequisites

- Docker Desktop
- Docker Compose

#### Start the backend

Navigate to the server directory.

```sh
cd server
```

Build and start all services.

```sh
docker compose up --build
```

This will start:

- PHP 8.3 + Apache
- MySQL 8
- Komiku REST API

The API will be available at

```text
http://localhost:8080
```

The interactive API documentation is also available at

```text
http://localhost:8080
```

#### Stop the backend

```sh
docker compose down
```

#### Rebuild after Dockerfile changes

```sh
docker compose up --build
```

<p align="right"><a href="#readme-top">Back to top</a></p>

<br>

<section id="usage">
  <header>
    <h2>Usage</h2>
  </header>
  <ul>
    <li>Create an account or log in to access all features.</li>
    <li>Browse comics by category or search using keywords.</li>
    <li>Select a comic to view its details, chapters, and comments.</li>
    <li>Start reading by selecting a chapter.</li>
    <li>Rate and comment on your favorite comics to share your thoughts.</li>
  </ul>
  <p align="right"><a href="#readme-top">Back to top</a></p>
</section>

<br>

<section id="commands">
  <header>
    <h2>Commands</h2>
  </header>
  <table>
    <thead>
      <tr>
        <th>Command</th>
        <th>Description</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><code>flutter pub get</code></td>
        <td>Fetch and install project dependencies.</td>
      </tr>
      <tr>
        <td><code>flutter run</code></td>
        <td>Run the app in debug mode on a connected device.</td>
      </tr>
      <tr>
        <td><code>flutter build apk</code></td>
        <td>Build a production APK for Android.</td>
      </tr>
      <tr>
        <td><code>flutter analyze</code></td>
        <td>Run static analysis to check for issues in the code.</td>
      </tr>
    </tbody>
  </table>
  <p align="right"><a href="#readme-top">Back to top</a></p>
</section>

<br>

<section id="demo">
  <header>
    <h2>Demo</h2>
  </header>

  <p align="center">
    <img src="docs/photo_1.png" width="300" alt="Home Page">
  </p>

  <p align="center">
    Home Page
  </p>

  <br>

  <p align="center">
    <img src="docs/photo_2.png" width="300" alt="Category Page">
  </p>

  <p align="center">
    Category Page
  </p>

  <br />

  <p align="center">
    <img src="docs/photo_3.png" width="300" alt="Comic Page">
  </p>

  <p align="center">
    Comic Page
  </p>

  <br />

  <p align="right">
    <a href="#readme-top">Back to top</a>
  </p>
</section>

<br>

<section id="api">
  <header>
    <h2>API</h2>
  </header>
  <p>The backend API supports various actions for user management, comic browsing, and social interactions. All requests are made using the <code>POST</code> method to a central endpoint with an <code>action</code> parameter.</p>
  <p>The API server is also available as a Docker image on Docker Hub: <a href="https://hub.docker.com/repository/docker/yosimaril/komiku-api/general">yosimaril/komiku-api</a>.</p>

  <table>
    <thead>
      <tr>
        <th>Action</th>
        <th>Method</th>
        <th>Auth</th>
        <th>Description</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><code>LOGIN</code></td>
        <td>POST</td>
        <td>No</td>
        <td>Authenticate user and retrieve JWT token.</td>
      </tr>
      <tr>
        <td><code>REGISTER</code></td>
        <td>POST</td>
        <td>No</td>
        <td>Create a new user account.</td>
      </tr>
      <tr>
        <td><code>UPDATE_USER</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Update user account details.</td>
      </tr>
      <tr>
        <td><code>DELETE_USER</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Delete user account.</td>
      </tr>
      <tr>
        <td><code>GET_CATEGORIES</code></td>
        <td>POST</td>
        <td>No</td>
        <td>Retrieve all available comic categories.</td>
      </tr>
      <tr>
        <td><code>INSERT_CATEGORY</code></td>
        <td>POST</td>
        <td>No</td>
        <td>Create a new category.</td>
      </tr>
      <tr>
        <td><code>UPDATE_CATEGORY</code></td>
        <td>POST</td>
        <td>No</td>
        <td>Update an existing category.</td>
      </tr>
      <tr>
        <td><code>DELETE_CATEGORY</code></td>
        <td>POST</td>
        <td>No</td>
        <td>Delete a category.</td>
      </tr>
      <tr>
        <td><code>GET_COMICS</code></td>
        <td>POST</td>
        <td>No</td>
        <td>Retrieve all available comics.</td>
      </tr>
      <tr>
        <td><code>GET_COMIC_DETAIL</code></td>
        <td>POST</td>
        <td>No</td>
        <td>Retrieve details for a specific comic.</td>
      </tr>
      <tr>
        <td><code>INSERT_COMIC</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Create a new comic entry.</td>
      </tr>
      <tr>
        <td><code>UPDATE_COMIC</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Update an existing comic.</td>
      </tr>
      <tr>
        <td><code>DELETE_COMIC</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Delete a comic.</td>
      </tr>
      <tr>
        <td><code>GET_COMIC_CHAPTERS</code></td>
        <td>POST</td>
        <td>No</td>
        <td>Retrieve all chapters of a comic.</td>
      </tr>
      <tr>
        <td><code>INSERT_COMIC_CHAPTERS</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Insert new chapter(s) for a comic.</td>
      </tr>
      <tr>
        <td><code>UPDATE_COMIC_CHAPTER</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Update an existing chapter.</td>
      </tr>
      <tr>
        <td><code>DELETE_COMIC_CHAPTER</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Delete a chapter.</td>
      </tr>
      <tr>
        <td><code>GET_COMIC_CHAPTER_PAGES</code></td>
        <td>POST</td>
        <td>No</td>
        <td>Retrieve all pages of a chapter.</td>
      </tr>
      <tr>
        <td><code>INSERT_COMIC_CHAPTER_PAGES</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Insert new page(s) for a chapter.</td>
      </tr>
      <tr>
        <td><code>UPDATE_COMIC_CHAPTER_PAGE</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Update an existing page.</td>
      </tr>
      <tr>
        <td><code>DELETE_COMIC_CHAPTER_PAGE</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Delete a page.</td>
      </tr>
      <tr>
        <td><code>GET_COMMENTS</code></td>
        <td>POST</td>
        <td>No</td>
        <td>Retrieve all comments for a comic.</td>
      </tr>
      <tr>
        <td><code>INSERT_COMMENT</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Post a new comment.</td>
      </tr>
      <tr>
        <td><code>UPDATE_COMMENT</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Edit an existing comment.</td>
      </tr>
      <tr>
        <td><code>DELETE_COMMENT</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Remove a comment.</td>
      </tr>
      <tr>
        <td><code>GET_REPLIES</code></td>
        <td>POST</td>
        <td>No</td>
        <td>Retrieve all replies to a comment.</td>
      </tr>
      <tr>
        <td><code>INSERT_REPLY</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Post a reply to a comment.</td>
      </tr>
      <tr>
        <td><code>UPDATE_REPLY</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Edit an existing reply.</td>
      </tr>
      <tr>
        <td><code>DELETE_REPLY</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Remove a reply.</td>
      </tr>
      <tr>
        <td><code>GET_RATING</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Retrieve user's rating for a comic.</td>
      </tr>
      <tr>
        <td><code>SAVE_RATING</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Submit or update a rating for a comic.</td>
      </tr>
      <tr>
        <td><code>DELETE_RATING</code></td>
        <td>POST</td>
        <td>Yes</td>
        <td>Remove a rating.</td>
      </tr>
    </tbody>
  </table>

  <p align="right"><a href="#readme-top">Back to top</a></p>
</section>

<br>

<section id="license">
  <header>
    <h2>License</h2>
  </header>
  <p>Distributed under the MIT License. See <code>LICENSE</code> for more information.</p>
  <p align="right"><a href="#readme-top">Back to top</a></p>
</section>

<br>

<section id="acknowledgments">
  <header>
    <h2>Acknowledgments</h2>
  </header>
  <ul>
    <li>Freepik for the illustration asset.</li>
  </ul>
  <p align="right"><a href="#readme-top">Back to top</a></p>
</section>
# ImageExtractor
[![Build Status](https://semaphoreci.com/api/v1/tracehelms/image_extractor/branches/master/badge.svg)](https://semaphoreci.com/tracehelms/image_extractor)

This app is deployed to: [http://image-extractor.herokuapp.com](http://image-extractor.herokuapp.com)

## Overview
This program takes a list of URLS via a JSON API, recursively crawls those URLs, and finds all unique images contained on those pages.

### Where's The Code?
In [Phoenix](http://www.phoenixframework.org), the code that runs the web app is located in the `/web` directory. This is similar to the `app/` directory in Rails. Notable files that contain important code are the files in `web/models`, `web/controllers/job_controller.ex`, and `lib/image_extractor/extractor.ex`. There are also tests in the `test/` directory.

The `lib/image_extractor/extractor.ex` file is where the bulk of the business logic is. In Phoenix, files in the `/lib` folder are typically used for utility code.

## Design Choices
### Phoenix & Elixir
Phoenix and Elixir are pretty new technologies but are very performant. I've been trying to engross myself with Elixir and learn about it, so that's the main reason I chose this language. The ecosystem is still fairly nascent and that gave me a few troubles. I think this would have been easier with Rails and Sidekiq (or similar library). Still, I learned quite a bit and I do think that this implementation is more performant.

### Handling 301 Redirects
When crawling a page, if the response is a 301 Redirect, it will follow the redirect and crawl that page normally.

### Handling Other Domains
When given the URL `http://tracehelms.com` to crawl, the job will consider that page level 1. If links to any outside domains are encountered, such as Twitter, it will crawl that page but Twitter will not get a new "tree". In other words, Twitter will be the second and last level. All of the images for Twitter will be placed under the `http://tracehelms.com` URL in the `/jobs/:id/results` response.

### Threads For Concurrent Crawling
Right now for every page that's being crawled, it happens in a new Elixir thread. These threads are very lightweight compared to operating system threads and are the key to concurrency in Elixir. The benefit is that all cores can be utilized to crawl the web pages, making it very performant. The downside is that you don't get retries and persistence of jobs for free like in Sidekiq / Redis. I chose ease of deployment over the robustness of something like Sidekiq and Redis.

### Error Handling
For now, this program more or less assumes a happy path. There isn't much defensive coding against possible errors. Before being production ready, this would definitely have to be addressed. If the current program encounters an exception, that thread will crash but not affect any others (thanks to Elixir threads being isolated). For instance, if we are crawling a second level page and encounter an exception, that thread will crash but every other second level page would still be crawled correctly because they are each in their own threads.

In Elixir, it's common to let threads crash if they are supervised. We would, however, want to keep track of which page crashed so that we can retry crawling it or log a reason why it failed. This is something that Sidekiq / Redis could help with.

### Improvements
- Error Handling: This wouldn't be a huge task, but would certainly need to be done before considering this production-ready.
- Marking Site's status as completed: The `Site` object's status gets marked as complete when a crawl past the second level is spawned. Because there is usually more than 1 third level page, this operation happens multiple times. This results in multiple redundant saves to the database. This only needs to happen once.
- Redis / ETS: Instead of spawning threads to crawl each page, we could add the pages to a queue and pull off of that queue. Something like Redis could be used here. Elixir also has something called Elixir Term Storage (ETS) which we could store our queue in.

## Usage
This app is deployed to: [http://image-extractor.herokuapp.com](http://image-extractor.herokuapp.com)

### Interacting via cURL
#### Creating A Job
Request
```
$ curl -i -X POST -H "Content-Type: application/json" -d '{"urls": ["http://tracehelms.com", "https://www.google.com"]}' http://image-extractor.herokuapp.com/jobs/`
```

Response
```
HTTP/1.1 202 Accepted
...
{
  "id":12
}
```

#### Checking Status Of A Job
Request
```
$ curl -i -H "Content-Type: application/json" http://image-extractor.herokuapp.com/jobs/12/status
```

Response
```
HTTP/1.1 200 OK
...
{
  "status": {
    "inprogress":0,
    "completed":2
  },
  "id":12
}
```

#### Checking Results Of A Job
Request
```
$ curl -i -H "Content-Type: application/json" http://image-extractor.herokuapp.com/jobs/12/results
```

Response
```
HTTP/1.1 200 OK
...
{
  "results":{
    "https://www.google.com":[
      "https://www.google.com/images/icons/product/chrome-48.png",
      "https://www.google.com/images/branding/googlelogo/1x/googlelogo_white_background_color_272x92dp.png",
      "https://www.google.com/finance/f/logo_us-115376669.gif"
    ],
    "http://tracehelms.com":[
      "http://tracehelms.com/assets/images/trace-head.jpg",
    ]
  },
  "id":12
}
```

### Installing
- Install [Elixir](http://elixir-lang.org): `$ brew install elixir`
- Install Hex, Elixir's package manager: `$ mix hex.local`
- Install [Phoenix](http://www.phoenixframework.org/docs/installation): `$ mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez`
- Clone this repo and switch to its directory
- Install dependencies: `$ mix deps.get`
- Create and migrate your database with `$ mix ecto.create && mix ecto.migrate`
- Start Phoenix server with `$ mix phoenix.server`

The server is now running at [`localhost:4000`](http://localhost:4000). Press `Ctrl + C` twice to stop the server.

### Running Tests
You can run tests in Elixir (and Phoenix) with: `$ mix test`.

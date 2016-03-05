# ImageExtractor
[![Build Status](https://semaphoreci.com/api/v1/tracehelms/image_extractor/branches/master/badge.svg)](https://semaphoreci.com/tracehelms/image_extractor)

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


Notes
- handling 301
- expanding to Redis
- routes must be canonical. having links like "/some_link" won't get crawled
- urls must start with http or https

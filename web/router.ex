defmodule ImageExtractor.Router do
  use ImageExtractor.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ImageExtractor do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/", ImageExtractor do
    pipe_through :api

    post "/jobs", JobsController, :create
    get "/jobs/:id/status", JobsController, :status
    get "/jobs/:id/results", JobsController, :results
  end
end

# GpanelOnePage

To start your this server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Create default certificates for you project `mix phx.gen.cert`
  * Make production container for localhost `make build`
  * Start container `make run`
  * Follow logs `docker-compose logs -f`

Now you can visit [`localhost`](https://localhost) from your browser.
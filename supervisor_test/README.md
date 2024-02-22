# SupervisorTest

Test how supervisors stablize code in case of bad states.

`RequestEmitter` - single process that calls random `Worker` each `request_interval`.
Each process is called with number 0-999

`Worker` - responds to RequestEmitter. Each number NUM is processed by following logic:
- NUM in [100, 200, ...] (`worker_bad_state_divider`) - introduce corrupted state (random number 10-30 (`worker_bad_state_range`)).
- if rem(NUM, state) == 0 - crash

Supervisors should restart crushed workers.

### How to play with it:

In default state it should run any time with crashes from time to time
without significant impact. In very rare cases it can happen that workers
restart more then 3 times during 5 seconds and supervisor restart everything

To increase chances and even hit moment when whole application is restarted do
some  of following in `config.exs`:
- decrease `request_interval` to emit requests more frequently
- increase `worker_sup_max_seconds` to make supervisor will wait longer for
restarts series
- decrease `worker_sup_max_restarts` so less restart will be needed to cause problem
- decrease `worker_bad_state_divider` so bad state is introduced more often
- decrease `worker_bad_state_range`  so bad state will be more harmful

### Start

Use `iex -S mix` to start application with console.

Use `RequestEmitter.disable/0`, `RequestEmitter.enable/0`, `RequestEmitter.status/0`
to control emitting process

### How to test

Use `mix test` to start unit tests.
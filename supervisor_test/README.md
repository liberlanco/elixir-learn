# SupervisorTest

Test how supervisors stablize code in case of bad states.

`RequestEmitter` - single process that calls random `Worker` each `@interval`.
Each process is called with number 0-999

`Worker` - responds to RequestEmitter. Each number NUM is processed by following logic:
- NUM in [100, 200, ...] - introduce corrupted state (random number 10-20).
- if rem(NUM, state) == 0 - crash

Supervisors should restart crushed workers.

### How to play with it:

In default state it should run any time with crashes from time to time
without significant impact. In very rare cases it can happen that workers
restart more then 3 times during 5 seconds and supervisor restart everything

To increase chances and even hit moment when whole application is restarted do
some  of following:
- decrease `@interval` in  `RequestEmitter` to emit requests more frequently
- increase `@max_interval` in `WorkerPool` so supervisor will wait longer for
restarts series
- decrease `@max_restarts` in `WorkerPool` so less restart will be needed to cause problem
- decrease `@bad_state_divider` in `Worker` so bad state is introduced more often
- decrease `@bad_state_range` in `WorkerPool` so bad state will be more harmful

### Start

Use `iex -S mix` to start application with console

### How to test

Use `mix test --no-start` to start unit tests.
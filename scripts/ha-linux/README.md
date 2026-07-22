# Home Assistant Linux Client

Connects to a Home Assistant instance via WebSocket, subscribes to
`state_changed` events, filters and transforms them, and relays the result
over a Unix domain socket so other local processes can consume the event
stream.

## Architecture

```
HA WebSocket  ──►  filter/transform  ──►  broadcast channel  ──►  Unix socket
                                              │
                                          all connected IPC clients
```

- **`src/ha.rs`** — Connects to `HASS_URL` using `HASS_TOKEN`, authenticates,
  subscribes to `state_changed` events, and pushes each event payload to a
  broadcast channel.
- **`src/filter.rs`** — Transforms raw HA events into a compact flat format
  before relaying. See [Event Format](#event-format) below.
- **`src/ipc.rs`** — Listens on a Unix domain socket (path from
  `HA_IPC_SOCKET` or `/tmp/ha-linux.sock` by default), accepts multiple
  concurrent clients, and writes each event as a newline-delimited JSON
  message (`<json>\n`).
- **`src/main.rs`** — Entry point; wires the broadcast channel between the
  two modules.

## Event Format

Raw HA `state_changed` events are transformed before relaying:

- **Flattened** — nested `data.new_state.*` fields are promoted to
  top-level keys.
- **Stripped** — `old_state`, `context`, `event_type`, and `origin` are
  removed.
- **Coerced** — `"on"` / `"off"` become booleans; numeric strings become
  JSON numbers.

| After transform | Example |
|---|---|
| `entity_id` | `"sensor.co2_mini_co2"` |
| `state` | `850` (number), `true`/`false`, or `"string_value"` |
| `attributes` | `{ "unit_of_measurement": "ppm", ... }` |
| `last_changed` | `"2024-01-01T00:00:00+00:00"` |
| `last_updated` | `"2024-01-01T00:00:00+00:00"` |
| `time_fired` | `"2024-01-01T00:00:00+00:00"` |

## Usage

```bash
export HASS_URL="https://my-ha.example.com"
export HASS_TOKEN="your_long_lived_token"

cargo run
```

Consume events from another terminal:

```bash
nc -U /tmp/ha-linux.sock
```

## Reconnection Behaviour

The WebSocket connection to Home Assistant uses automatic reconnection when
the link drops — for example, after the PC wakes from sleep or HA restarts.

- **Exponential backoff** — the first retry waits 2 seconds, then 4s, 8s,
  16s, and finally 30s (capped) for all subsequent attempts.
- **Bounded retries** — after 8 consecutive failures (~2.5 minutes of
  trying), the client gives up, cleans up the IPC socket, and exits with a
  non-zero exit code.
- **Retry counter resets** — any successful reconnect resets the counter and
  backoff, so transient blips cause only a brief pause.
- **Fatal errors** — an `auth_invalid` response from HA immediately exits
  without retrying, since credentials will not change.

## Development

### Using the Nix Development Shell

```bash
nix develop

cargo build
cargo run
cargo test
cargo fmt
cargo clippy
```

### Building the Package

```bash
nix build
./result/bin/ha-linux
```

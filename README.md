# cam-dof

Camera depth-of-field (DOF) control service written in SWI-Prolog.

This project listens to a Redis Stream for camera duty-cycle updates and applies them to a Linux sysfs PWM device (for example a PCA9685 channel). It is designed to run in Docker with privileged access to host PWM sysfs.

## What it does

- Connects to Redis.
- Creates a Redis consumer group for the camera stream (idempotent).
- Consumes stream events and extracts `duty_cycle` values.
- Drives PWM duty cycle for the configured camera channel.
- Clamps scaled duty cycle to the configured min/max range.
- Disables PWM after idle timeout and re-enables on next message.

## Repository layout

- `cam_dof.pl`: main program, Redis wiring, thread loop, DOF mapping.
- `cam.pl`: Redis stream key/group/consumer settings.
- `pwm.pl`: sysfs PWM read/write helpers.
- `xgroup.pl`: helper for Redis `XGROUP CREATE`.
- `clamp.pl`: numeric clamp utility.
- `Dockerfile`: container image build.
- `Makefile`: convenience targets to build and run.

## Requirements

- Docker
- Linux host with PWM sysfs support at `/sys/class/pwm`
- A reachable Redis server (default: `localhost:6379`)

## Build

Use the Make target:

```sh
make build
```

Or build directly:

```sh
docker build -t cam-dof:latest .
```

## Run

Recommended via Makefile (build + run):

```sh
make run
```

Equivalent Docker command:

```sh
docker run --network=host --privileged --rm cam-dof:latest
```

Why these flags:

- `--privileged`: required to write PWM sysfs controls on host.
- `--network=host`: lets container reach host Redis at `localhost`.

## Configuration

Environment variables consumed by `cam_dof.pl`:

- `REDISCLI_HOST` (default: `localhost`)
- `REDISCLI_PORT` (default: `6379`)

Example:

```sh
docker run --network=host --privileged --rm \
  -e REDISCLI_HOST=127.0.0.1 \
  -e REDISCLI_PORT=6379 \
  cam-dof:latest
```

## Redis stream contract

Default stream key and group are defined in `cam.pl`:

- stream key: `cam`
- consumer group: `dof`

Each message should provide a `duty_cycle` field in the range `[0.0, 1.0]`.

Example publisher command:

```sh
redis-cli XADD cam * duty_cycle 0.42
```

## DOF mapping

Current mapping in `cam_dof.pl`:

- DOF name: `cam`
- PWM device name: `pca9685-pwm`
- PWM channel/export: `11`
- min duty cycle: `0.1`
- max duty cycle: `0.3`

Incoming `duty_cycle` is scaled to:

```text
scaled = min + (max - min) * input
```

then clamped before writing to sysfs.

## Notes

- The image compiles Prolog files (`qcompile`) during build and removes source files inside the image to reduce size.
- Runtime entrypoint is `swipl -s cam_dof`.
- `xgroup_create` ignores Redis `BUSYGROUP` errors so startup is safe when the group already exists.

## Troubleshooting

- Cannot control PWM: ensure container is run with `--privileged` and host PWM paths are available.
- No events consumed: verify Redis is reachable and messages are sent to stream `cam` with a `duty_cycle` field.
- Wrong actuator movement: validate DOF mapping and min/max duty cycle values in `cam_dof.pl`.

## License

MIT (see license header in source files).

# strike
Strike a simple service for hosting CoreOS Ignition configuration or Container Linux configs. It transpiles Container Linux Configs to Ignition Configs for you. For convenience it also serves static assets.

Set `STRIKE_SRV_DIR` to a directory containing an `ignition` and `static` directory. Put Container Linux Config YAML files (`.yaml` or `.yml`), or Ignition Config JSON (`.ignition`, `.ign`, or `.json`) files into the `ignition` directory. Other static assets can go into `static`.

```
./STRIKE_SRV_DIR
  ./ignition
    clfg.yml
    default.ignition
  ./static
    pypy_install.sh
    tool.py
```

# Reaching Container Linux & Ignition Configs
Transpiled configs are reachable at the endpoint `http://127.0.0.1:5000/ignition/<base filename>` by their base filename, meaning, a filename of `cfg.yml` would be served at `http://127.0.0.1:5000/ignition/cfg`. A `platform` argument is usually required as well for Container Linux Config YAML: `http://127.0.0.1:5000/ignition/cfg?platform=ec2`.

# Static assets
Static assets are served directly from `http://127.0.0.1:5000/static/`.

# Config variables
* `STRIKE_SRV_DIR` sets the served directory. By default this is `./`.

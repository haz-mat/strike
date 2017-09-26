#!/bin/sh -ev
cpu_core_count="$(grep -c ^processor /proc/cpuinfo)"
/usr/local/bin/gunicorn "strike:app" \
  --workers="$(($cpu_core_count * 2))" \
  --bind=0.0.0.0:5000 \
  --access-logfile=-

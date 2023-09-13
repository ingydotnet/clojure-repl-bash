
repl-start() (
  _repl-init

  if [[ -f $pid_file ]]; then
    echo "*** Already started"
    repl-status
    return
  fi

  lein repl :headless >/dev/null &
  pid=$!
  _repl-wait-for-port-file
  ps -p "$pid" >/dev/null ||
    die echo "Failed to start an nrepl server"
  echo "$pid" > "$pid_file"

  echo "REPL server started on port $(< "$port_file"); pid $(< "$pid_file")"
)

repl-status() (
  _repl-check
  echo "REPL server running on port $(< "$port_file"); pid $(< "$pid_file")"
)

repl-stop() (
  _repl-check
  pid=$(< "$pid_file")
  read -r -a pids <<<"$(
    ps -p "$pid" --ppid "$pid" -o pid= | xargs
  )"
  (
    set -x
    kill -9 "${pids[@]}"
    rm -f "$port_file" "$pid_file"
  )
  echo "REPL server stopped"
)

repl-connect-lein() (
  _repl-check
  lein repl :connect
)

repl-debug() (
  _repl-init
  repl-status || true
  set -x
  ps fau | grep [l]ein
  pid=$(< "$pid_file")
  ps -p "$pid" --ppid "$pid"
  ps -p "$pid" --ppid "$pid" -o pid=
)

_repl-init() {
  set -e -u -o pipefail
  shopt -s inherit_errexit

  die() ( echo "$*"; exit 1 )

  port_file=./.nrepl-port
  port_file_home=$HOME/.lein/repl-port
  pid_file=./.nrepl-pid

  rm -f "$port_file_home"

  if [[ -f $port_file && ! -f $pid_file ]]; then
    rm -f "$port_file"
  elif [[ -f $pid_file && ! -f $port_file ]]; then
    kill -9 $(< "$pid_file") &>/dev/null || true
    rm -f "$pid_file"
  fi
}

_repl-check() {
  _repl-init
  [[ -f $port_file ]] || die "REPL not running, no $port_file file"
  [[ -f $pid_file ]] || die "REPL not running, no $pid_file file"
}

_repl-wait-for-port-file() (
  i=0
  while [[ $((i++)) -lt 20 ]] &&
    [[ ! -f $port_file ]] &&
    [[ ! -f $port_file_home ]]
  do
    sleep 0.5
  done

  if [[ ! -f $port_file ]]; then
    [[ -f $port_file_home ]] ||
      die "No $port_file or $port_file_home file"
    mv "$port_file_home" "$port_file"
  fi
)

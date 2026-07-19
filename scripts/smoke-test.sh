#!/usr/bin/env bash
set -euo pipefail

VIP_URL="${VIP_URL:?Set VIP_URL, for example http://192.168.88.80}"
WEB_URLS="${WEB_URLS:?Set WEB_URLS to a space-separated backend URL list}"
REQUEST_TIMEOUT="${REQUEST_TIMEOUT:-10}"

read -r -a backends <<<"${WEB_URLS}"
if ((${#backends[@]} < 2)); then
  echo "At least two backend URLs are required." >&2
  exit 2
fi

test_dir="$(mktemp -d)"
trap 'rm -rf "${test_dir}"' EXIT

fetch_and_measure() {
  local name="$1"
  local url="$2"
  local output="${test_dir}/${name}.html"
  local status

  status="$(curl --silent --show-error --location \
    --max-time "${REQUEST_TIMEOUT}" \
    --output "${output}" \
    --write-out '%{http_code}' \
    "${url}")"

  if [[ "${status}" != "200" ]]; then
    echo "FAIL ${name}: ${url} returned HTTP ${status}" >&2
    return 1
  fi

  local bytes hash
  bytes="$(wc -c <"${output}" | tr -d ' ')"
  hash="$(sha256sum "${output}" | awk '{print $1}')"
  printf '%-10s status=%s bytes=%s sha256=%s url=%s\n' \
    "${name}" "${status}" "${bytes}" "${hash}" "${url}"
  last_hash="${hash}"
}

declare -a hashes=()
last_hash=""
for index in "${!backends[@]}"; do
  fetch_and_measure "web$((index + 1))" "${backends[$index]}"
  hashes+=("${last_hash}")
done

fetch_and_measure "vip" "${VIP_URL}"
vip_hash="${last_hash}"

reference="${hashes[0]}"
for hash in "${hashes[@]}"; do
  if [[ "${hash}" != "${reference}" ]]; then
    echo "FAIL: backend content hashes differ." >&2
    exit 1
  fi
done

if [[ "${vip_hash}" != "${reference}" ]]; then
  echo "FAIL: VIP content differs from the backend content." >&2
  exit 1
fi

echo "PASS: all backends and the VIP returned identical HTTP 200 content."

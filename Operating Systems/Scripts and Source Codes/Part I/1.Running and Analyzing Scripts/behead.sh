#!/bin/sh

# behead.sh (ver. 2.2 – header stripper with CRLF normalization for files & STDIN)
#
# Strips off the header from a mail/news message—everything up to the first
# blank line (by default), or up to a custom pattern—then prints the body.
# Automatically normalizes Windows CRLF endings, whether reading from files
# or from STDIN. Embeds the sed logic in a function to avoid repetition.

# Exit codes
E_USAGE=85
E_NOFILE=86

# Default header-end pattern: first blank line
PATTERN='^$'
FILES=""

usage() {
  cat <<-EOU
Usage: $(basename "$0") [--help] [-p PATTERN] [file ...]
Strip message headers from files or STDIN, up to the first blank line
(or up to PATTERN if given).

Options:
  --help        Show this help message and exit.
  -p PATTERN    Change header-end marker to first line matching PATTERN
                (default blank line: '^$').
If no files are given, reads from STDIN.
EOU
  exit $E_USAGE
}

# Parse options
while [ $# -gt 0 ]; do
  case "$1" in
    --help) usage ;;
    -p)
      shift
      [ -n "$1" ] || { echo "ERROR: -p requires a PATTERN"; usage; }
      PATTERN="$1"
      ;;
    --) shift; break ;;
    -*)
      echo "ERROR: Unknown option: $1" >&2
      usage
      ;;
    *)
      FILES="$FILES \"$1\""
      ;;
  esac
  shift
done

# strip_header: normalize CRLF and strip header
# $1 = filename or '-' for STDIN
strip_header() {
  infile="$1"
  if [ "$infile" != "-" ]; then
    # Normalize CRLF in-place
    sed -i 's/\r$//' "$infile"
    echo "DEBUG: Normalized CRLF in '$infile'"
    echo "DEBUG: Stripping header from '$infile' (pattern: $PATTERN)"
    sed -e "1,/$PATTERN/d" -e '/^[[:space:]]*$/d' "$infile"
  else
    echo "DEBUG: Stripping header from STDIN (pattern: $PATTERN)"
    # Normalize CRLF, then strip header
    sed -e 's/\r$//' -e "1,/$PATTERN/d" -e '/^[[:space:]]*$/d'
  fi
}

# Main
if [ -z "$FILES" ]; then
  # No files → read from STDIN
  strip_header "-"
else
  eval set -- $FILES
  for f; do
    if [ ! -r "$f" ]; then
      echo "ERROR: Cannot read '$f', skipping." >&2
      continue
    fi
    strip_header "$f"
  done
fi

exit 0

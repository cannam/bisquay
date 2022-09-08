#!/bin/bash
set -eu
p=repoint-project.json
if [ ! -f "$p" ]; then
    echo "Project file $p not found"
    exit 1
fi

cat <<'EOF'
# Bisquay Contents

The following libraries are included in
[Bisquay](https://hg.sr.ht/~cannam/bisquay).

The `repoint-project.json` file in the Bisquay repository tells the
included Repoint utility how to find these; run `./repoint install` to
pull in the necessary code before you build or use Bisquay.

EOF

cat "$p" | jq '.libraries | keys_unsorted[]' | while read library; do
    library=$(echo "$library" | sed 's/"//g')
    case "$library" in
        ext/bq*) continue;;
        ext/smldoc) continue;;
    esac
    repository=$(cat "$p" | jq -j '.libraries."'$library'".repository')
    if [ "$repository" = "null" ]; then repository=${library##*/}; fi
    owner=$(cat "$p" | jq -j '.libraries."'$library'".owner')
    echo -n " * [$library]("
    case $(cat "$p" | jq -j '.libraries."'$library'" | { vcs, service }[]') in
        hgsourcehut) echo -n "https://hg.sr.ht/~$owner/$repository" ;;
        gitgithub) echo -n "https://github.com/$owner/$repository" ;;
    esac
    echo ")"
    echo -n "   "
    readme=$(ls -1 "$library"/README* | grep -v '~' | head -1)
    cat "$readme" |
        grep -v '^ *$' |
        grep -v bisquay |
        grep -v 'bsq-' |
        grep -v 'sml-' |
        grep -v '^==' |
        head -1 |
        sed 's/[,.].*//' |
        sed 's/^#* *//' |
        sed 's/written in Standard ML//' |
        sed 's/in Standard ML//' |
        sed 's/in SML//' |
        sed 's/ (SML)//'
done

#!/bin/sh
set -eu

for d in fuse fuse/nodefs fuse/pathfs fuse/test zipfs unionfs \
    example/hello example/loopback example/zipfs \
    example/multizip example/unionfs example/memfs \
    example/autounionfs example/statfs ; \
do
  go build -o /dev/null github.com/nekojarashi/go-fuse/${d}
done


for d in fuse zipfs unionfs fuse/test
do
    (
        cd $d

        # Make sure it compiles on all platforms.
        for GOOS in darwin linux ; do
          export GOOS
          go test -c -i github.com/nekojarashi/go-fuse/$d
        done

        echo "go test github.com/nekojarashi/go-fuse/$d"
        go test github.com/nekojarashi/go-fuse/$d
        echo "go test -race github.com/nekojarashi/go-fuse/$d"
        go test -race github.com/nekojarashi/go-fuse/$d
    )
done

for target in "clean" "install" ; do
  for d in fuse fuse/nodefs fuse/pathfs fuse/test zipfs unionfs \
    example/hello example/loopback example/zipfs \
    example/multizip example/unionfs example/memfs \
    example/autounionfs example/statfs ; \
  do
    if test "${target}" = "install" && test "${d}" = "fuse/test"; then
      continue
    fi
    echo "go ${target} github.com/nekojarashi/go-fuse/${d}"
    go ${target} github.com/nekojarashi/go-fuse/${d}
  done
done


make -C benchmark
for d in benchmark
do
  go test github.com/nekojarashi/go-fuse/benchmark -test.bench '.*' -test.cpu 1,2
done

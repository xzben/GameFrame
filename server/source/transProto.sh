#!/bin/sh
rm -rf proto/*.pb
for file in proto/* ;
do
    protoc -o ${file%.*}.pb $file;
    echo "protoc -o ${file%.*}.pb $file"
done

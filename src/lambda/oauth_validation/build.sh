
docker run -it --rm \
            -v "$(pwd)/lambda/oauth_validation":/working \
            -v "$(pwd)/bin":/output \
            ubuntu bash /working/package.sh
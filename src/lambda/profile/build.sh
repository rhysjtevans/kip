
# pwshd $(pwd)
# cd "/Users/rhysevans/OneDrive - Capgemini/Git/keybase-capgemini/src/lambda/oauth_validation/v-env/lib/python3.7/site-packages"
# zip -r9 "/Users/rhysevans/OneDrive - Capgemini/Git/keybase-capgemini/src/bin/lambda.oauth_validation.zip" .
# popd
# cd "/Users/rhysevans/OneDrive - Capgemini/Git/keybase-capgemini/src/lambda/oauth_validation"
# zip -g "/Users/rhysevans/OneDrive - Capgemini/Git/keybase-capgemini/src/bin/lambda.oauth_validation.zip" handler.py
docker run -it --rm \
            -v "$(pwd)":/working \
            -v "/Users/rhysevans/OneDrive - Capgemini/Git/keybase-capgemini/src/bin":/output \
            ubuntu 
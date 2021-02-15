set -e
apt-get update
# apt-get install python3-pip python3-venv python3-cffi zip libffi-dev -y
apt-get install python3-pip python3-venv python3-cffi libffi-dev -y
# python3 -m venv /tmp/tutorial-env
# source /tmp/tutorial-env/bin/activate
# # pip3 install --upgrade --force-reinstall cffi jwcrypto
# deactivate
# cd /tmp/tutorial-env/lib/python3.6/site-packages
# mv _cffi_backend.cpython-36m-x86_64-linux-gnu.so _cffi_backend.so
cp /working/handler.py .
rm /output/lambda.oauth_validation.zip
zip -r /output/lambda.oauth_validation.zip ./

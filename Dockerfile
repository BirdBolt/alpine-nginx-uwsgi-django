# Copyright Willy Njundong 2018
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

FROM alpine:3.7

MAINTAINER BirdBolt

# Install required packages and remove the apt packages cache when done.
#apk update && apk upgrade && \
RUN apk update && apk add \
    bash=4.4.19-r1 \
    git=2.15.0-r1 \
	openssh=7.5_p1-r8 \
	python3=3.6.3-r9 \
	python3-dev=3.6.3-r9 \
	gcc=6.4.0-r5 \
	build-base=0.5-r0 \
	linux-headers=4.4.6-r2 \
	pcre-dev=8.41-r1\
	postgresql-dev=10.3.0-r1 \
	musl-dev=1.1.18-r3 \
	libxml2-dev=2.9.7-r0 \
	libxslt-dev=1.1.31-r0 \
	nginx=1.12.2-r3 \
	curl=7.59.0-r0 \
	supervisor=3.3.3-r1 && \
	python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    rm -r /root/.cache && \
    pip3 install --upgrade pip setuptools && \
    rm -r /root/.cache

# install uwsgi now because it takes a little while
RUN pip3 install uwsgi

# setup all the configfiles
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx-app.conf /etc/nginx/sites-available/default
COPY supervisor-app.conf /etc/supervisor/conf.d/

# COPY requirements.txt and RUN pip install BEFORE adding the rest of your code, this will cause Docker's caching mechanism
# to prevent re-installing (all your) dependencies when you made a change a line or two in your app.
COPY app/requirements.txt /home/docker/code/app/
RUN pip3 install -r /home/docker/code/app/requirements.txt

# add (the rest of) our code
COPY . /home/docker/code/

# install django, normally you would remove this step because your project would already
# be installed in the code/app/ directory
RUN django-admin.py startproject project /home/docker/code/app/

#WORKDIR /home/docker/
#CMD ["supervisord", "-n", "-c", "/home/docker/code/supervisor-app.conf"]
EXPOSE 80
CMD ["supervisord", "-n"]
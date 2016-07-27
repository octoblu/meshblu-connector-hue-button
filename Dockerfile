FROM node:5
MAINTAINER Octoblu <docker@octoblu.com>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app/package.json
RUN npm -s install

COPY . /usr/src/app

CMD [ "npm", "test" ]

FROM node:14.14-alpine

RUN npm install -g fake-smtp-server

CMD ["fake-smtp-server", "-s", "25", "--debug"]

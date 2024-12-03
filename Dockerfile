FROM node:16-alpine
WORKDIR /App
COPY . /App
RUN npm install typescript@4.9.5 && npm install  
EXPOSE 3000
CMD ["npm" , "run" , "start"]

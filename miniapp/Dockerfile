FROM node AS build

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY ./app/* ./

# Install any needed dependencies
RUN npm install

# # Run the app
# CMD [ "node", "app.js" ]

# Build the NGINX image
FROM nginx
COPY --from=build /app /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

#A Docker image is a lightweight, standalone, executable package that includes everything needed to run a piece of software, including the code, a runtime, libraries, environment variables, and system tools. Docker images are the basis for running containers, which are isolated and runnable instances of an image.

#python: This is the base image name. In this case, it is an official Python image available on Docker Hub.
#3.9-alpine3.13: This is the tag associated with the Python image. It specifies a specific version or variant of the base image.3.9: This is the version of Python.alpine3.13: This refers to the Alpine Linux version used as the base system. 
FROM python:3.9-alpine3.13

#sets an environment variable within the Docker container. Specifically, it is setting the PYTHONUNBUFFERED environment variable to the value 1.ENV: This is the keyword in a Dockerfile used to set environment variables. PYTHONUNBUFFERED: This is the name of the environment variable being set. In the context of a Dockerfile for a Python application, setting PYTHONUNBUFFERED 1 is a common practice. It ensures that the Python output (print statements, logs, etc.) is immediately visible in the Docker logs without any delay caused by buffering.
ENV PYTHONUNBUFFERED=1

#This line copies the requirements.txt file from the local directory (./) to the /tmp directory inside the Docker image. This is typically done to separate the copying of dependencies from the rest of the application code, allowing for better caching during the Docker image build process.
COPY ./requirements.txt /tmp/requirements.txt  

COPY ./requirements.dev.txt /tmp/requirements.dev.txt

#copies the contents of the local ./app directory to the /app directory inside the Docker image. Our application code is in the ./app directory on the host machine.
COPY ./app /app

#This line sets the working directory inside the Docker image to /app. This means that all subsequent commands will be executed from this directory unless specified otherwise. It's a good practice to set the working directory to the main directory of your application.
WORKDIR /app

#This line informs Docker that the application inside the container will use port 8000.
EXPOSE 8000

#Sets the default value to False. We override this inside our Docker-Compose.yml file by specifing args dev=True. So when we#re using this Dockerfile through our docker-compose.yml configuration its gonna update DEV to True, whereas when we use it with any other docker-compose configuration its gonna leave it in False, so by default we#re not running in development mode. 
ARG DEV=false

#RUN  to run multiple commands (without creating an image layer for every single command if we would run them each separately) to keep our image lightweight. We separate commannds by && \. Use use venv in docker to avoid conflicts between python dependencies in our base image and python dependecies in our project.
#The first command creates a new virtual env that we#re gonna need to store our dependencies.

#RUN apk --no-cache add \
    #postgresql-client \
    #build-base \
   # postgresql-dev \
   # musl-dev


RUN pip install --upgrade pip   && \
    
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual  .tmp-build-deps \
        build-base postgresql-dev musl-dev && \

    
    #We install our requirements file inside the venv in our Docker Image.
    pip install -r /tmp/requirements.txt && \
    #Check if our DEV environment variable (build argument) is set to true then install requirements.dev.txt
    if [ $DEV = "true" ] ; \
        then pip install -r /tmp/requirements.dev.txt ; \
    fi && \

    #We remove the tmp directory. The reason we do this is becaouse we dont want any extra dependecies on our image once its beign created. Its best practice to keep our image as lightweight as possible. 
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    #This command adds a new user inside our image. Its best practice not to use the root user (the only user available inside our image if we wouldnt specify a new one. It has full access and  permission  to do anything on the server.). For security purposes, if the app gets compromised, the user we created doesnt have full provileges.
    adduser -D -s /bin/bash django-user
        #We dont want to log in through a password, but by default when we run the app
        
        #We dont want to create a home directory because its not necessary.
        
        #The name of the user


USER django-user

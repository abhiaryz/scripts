$#!/bin/bash
echo "welcome"
ls
echo "this is the whole list of dir"
sudo virtualenv venv
cd venv 
source bin/activate
sudo pip install django djangorestframework markdown django-filter django-model-utils psycopg2-binary 
pwd
cd ..
echo "Enter entry project name"  
read project_name
sudo django-admin startproject $project_name
echo "End"




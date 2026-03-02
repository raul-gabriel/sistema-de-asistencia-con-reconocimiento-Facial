#!/bin/bash

# Iniciar Laravel
cd panel_administrativo
gnome-terminal -- bash -c "php artisan serve --host=0.0.0.0 --port=9000; exec bash"
cd ..

# Iniciar script Python
cd apibuscar
gnome-terminal -- bash -c "python3 main.py; exec bash"
cd ..


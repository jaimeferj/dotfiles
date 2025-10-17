#!/usr/bin/env zsh
# Función: devuelve YYYY-MM-DD para el weekday pasado
weekday-date() {
    date -d "this $1" '+%F'
}
# Alias cómodo
alias wdate=weekday-date

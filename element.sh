#!/bin/bash

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Include --csv flag to output results with fields separated by only a comma.
# This makes the output string far easier to parse.
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only --csv -c"

if [[ $1 =~ ^[0-9]{1,3}$ ]]; then
  # Search by atomic number
  RESULT=$($PSQL "SELECT name,symbol,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number = $1")
  ATOMIC_NUMBER=$1
elif [[ $1 =~ ^[A-Z][a-z]?$ ]]; then
  # Search by atomic symbol
  RESULT=$($PSQL "SELECT atomic_number,name,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol = '$1'")
  ATOMIC_SYMBOL=$1
else
  # Search by element name
  RESULT=$($PSQL "SELECT atomic_number,symbol,type,atomic_mass,melting_point_celsius,boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE name = '$1'")
  NAME=$1
fi

if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit
fi

# Convert the output string into an array.
# The fields are separated by a single comma.
IFS=','
ARRAY=($RESULT)

# Depending on what the user passed into the program
# (atomic number, atomic symbol, or element name),
# the first two elements of the array will be
# the other two of those three choices.
if [[ ! -z $ATOMIC_NUMBER ]]; then
  NAME="${ARRAY[0]}"
  ATOMIC_SYMBOL="${ARRAY[1]}"
elif [[ ! -z $ATOMIC_SYMBOL ]]; then
  ATOMIC_NUMBER="${ARRAY[0]}"
  NAME="${ARRAY[1]}"
else
  ATOMIC_NUMBER="${ARRAY[0]}"
  ATOMIC_SYMBOL="${ARRAY[1]}"
fi

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($ATOMIC_SYMBOL). It's a ${ARRAY[2]}, with a mass of ${ARRAY[3]} amu. $NAME has a melting point of ${ARRAY[4]} celsius and a boiling point of ${ARRAY[5]} celsius."


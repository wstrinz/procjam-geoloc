module ProcGen where

type alias Entity = { species: String, name: String }
type alias Place = { name: String, people: Entity }

genPeople : Entity
genPeople = { species = "Human", name = "Bobob obbbybob"}

getAPlace : Place
getAPlace = { name = "thoor", people = genPeople }

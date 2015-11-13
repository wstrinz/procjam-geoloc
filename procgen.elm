module ProcGen where

type alias Entity = { species: String, name: String }
type alias Place = { name: String, people: Entity }

genPeople : Entity
genPeople = { species = "Human", name = "yes"}

getAPlace : Place
getAPlace = { name = "Coffee", people = genPeople }

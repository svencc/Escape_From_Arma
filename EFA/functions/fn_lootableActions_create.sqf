// erst mal prüfen ob wir uns weiter als x meter von unserer letzten Position (als create ausgeführt wurde) entfernt haben?
// nur wenn wir einen bestimmten radios verlassen, erstellen wir neue ace actions
// da müssen wir performance mal testen. lass uns mit 100 meter starten in dem wir actions erstellen.
// wenn wir uns 50/75 meter von der letzten Position entfernt haben; dann erstellen wir neue actions.

// auserdem prüfen wir ob sich der spieler in einem Fahrzeug befindet; wenn ja, dann brechen wir gleich ab

// ist fahrzeug?
// ist neue position weit genug von alter entfert?
// -> nur dann machen wir neue actions

// oder wir machen actions "grid-weise" ... models haben vermutlich keine attribute
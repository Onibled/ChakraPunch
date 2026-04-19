class_name InputBuffer
extends Node

# =========================================================
# 🎮 INPUT BUFFER SYSTEM
# Permette di "memorizzare" input per un breve periodo
# → fondamentale per:
# - combo fluide
# - cancel window
# - gameplay responsive (fighting game feel)
# =========================================================

## Lista degli input salvati
## Ogni elemento è un Dictionary:
## {
##   "action": String,
##   "time": float
## }
var buffer := []

## Tempo massimo in cui un input rimane valido
## (es: 0.2 = 200ms)
var buffer_time := 0.2

# ---------------------------------------------------------
# 📥 AGGIUNTA INPUT
# ---------------------------------------------------------

## Salva un input nel buffer
## action → nome input ("light", "heavy", ecc.)
## L'input rimane valido per buffer_time secondi
func add_input(action: String):
	buffer.append({
		"action": action,
		"time": buffer_time
	})

# ---------------------------------------------------------
# ⏳ AGGIORNAMENTO BUFFER
# ---------------------------------------------------------

## Aggiorna il timer degli input salvati
## Va chiamato ogni frame (physics_process)
## Rimuove automaticamente gli input scaduti
func update(delta):
	for i in range(buffer.size() - 1, -1, -1):
		buffer[i]["time"] -= delta
		if buffer[i]["time"] <= 0:
			buffer.remove_at(i)

# ---------------------------------------------------------
# 🔍 CONSUMO INPUT
# ---------------------------------------------------------

## Controlla se un input è presente nel buffer
## Se trovato:
## - lo rimuove
## - ritorna true
##
## Questo evita doppie letture dello stesso input
func consume(action: String) -> bool:
	for i in range(buffer.size()):
		if buffer[i]["action"] == action:
			buffer.remove_at(i)
			return true
	return false

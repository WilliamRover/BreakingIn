class_name Minigame extends Node2D

# Generate using random seeds here
var rng = RandomNumberGenerator.new()
var savedSeed: int

func retryGame(oldSeed: int) -> void:
	rng.seed = oldSeed 
	execution()
	
func generateNewGame() -> int:
	rng.randomize()
	savedSeed = rng.seed
	execution()
	return savedSeed

# Override this and use your own shenanigans
func execution() -> void:
	pass

class_name NearWall extends Area2D

var player: CharacterBody2D = null
var curTileMap: TileMapLayer
var playerInsideCheck := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curTileMap = get_parent() as TileMapLayer

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		playerInsideCheck += 1
		player = body
		if playerInsideCheck == 1:
			curTileMap.modulate.a = 0.3
			#print("behind wall")


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		playerInsideCheck -= 1
		if playerInsideCheck <= 0:
			playerInsideCheck = 0
			curTileMap.modulate.a = 1

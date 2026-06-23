class_name PlayerData
extends Node

## Indexes correspond to the FACTIONS array in FactionData
## Ranges from 0 to 100
var reputations: Array[int]

## When an article is submitted, the current reputations are copied here
## before the new reputations are calculated.
## This data may be displayed on the results layer.
var previous_reputations: Array[int]

## Ranges from 0 to 100
var public_trust: int

## When an article is submitted, the current trust is copied here
## before the new trust is calculated.
## This data may be displayed on the results layer.
var previous_public_trust: int

## When a save is loaded, this is true, otherwise, this is false
static var save_started: bool = false

func start_new_save():
	reputations = [50, 50, 50, 50]
	public_trust = 100
	save_started = true

func apply_changes_from_article(article: ArticleLevel):
	previous_reputations = reputations.duplicate()
	previous_public_trust = public_trust
	var changes := article.get_total_changes()
	for i in range(0,4):
		reputations[i] += changes[i]
	public_trust += changes[4]

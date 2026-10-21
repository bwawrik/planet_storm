extends Resource

class_name STATS

enum EntityOwner {MOB, PLAYER, EMPTY}
enum AttackStance {RUN, NEUTRAL, ATTACK}

@export var type: String = ""
@export var description: =""
@export var entityOwner: EntityOwner = EntityOwner.PLAYER
@export var occupyRange: int = 0

## if unit or mob
@export var HP: int = 100
@export var maxHP: int = 100
@export var SHILEDS: int = 0
@export var SPEED: float = 10
@export var attackRange: float = 2
@export var visibilityRange: float = 10
@export var attackStance: AttackStance = AttackStance.NEUTRAL
@export var mobLifeTime: float = 30
@export var pointsIfKilled: int = 10
@export var pointsEndofRound: int = 0

## cost
@export var CostBlueEnergy = 10
@export var manaCost  = 0
@export var woodCost  = 0
@export var wheatCost = 0
@export var stoneCost = 0

## modifiers for shields and other equipment
## resistance modifier
@export var kineticResistModifier: int = 1
@export var energyResistModifier: int = 1
@export var plasmaResistModifier: int = 1
@export var acidResistModifier: int = 1

## IF WEAPON
## damage is zero by default; only increase this for weapons 
@export var baseDamage: int = 20
@export var kineticDamage: int = 0
@export var energyDamage: int = 0
@export var plasmaDamage: int = 0
@export var acidDamage: int = 0

## damage modifiers
## these will be applied to bullets and equipment
@export var kineticDamageModifier: int = 1
@export var energyDamageModifier: int = 1
@export var plasmaDamageModifier: int = 1
@export var acidDamageModifier: int = 1

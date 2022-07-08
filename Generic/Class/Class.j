module ClassExist

	boolean exist = true

	static method exists takes thistype c returns boolean
		if c <= 0 then
			return false
		endif
		return .exist
	endmethod

	method destroy takes nothing returns nothing
		set .exist = false
		call deallocate()
	endmethod

endmodule

//! import "Effect.j"
//! import "Ability.j"
//! import "Item.j"
//! import "Movement.j"
//! import "UnitMovement.j"
//! import "Damage.j"
//! import "Actor.j"
//! import "UnitActor.j"
//! import "Unit.j"
//! import "Missile.j"
//! import "Object.j"
//! import "Curve.j"
//! import "Agent.j"
//! import "Circle.j"
//! import "Square.j"
//! import "Lightning.j"
//! import "Explosion.j"
//! import "User.j"
//! import "Buff.j"
//! import "Mover.j"
//! import "Moolgun.j"
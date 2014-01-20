# This is just an enum class, it has no corresponding table in the database.
class GameStatus
	include Enum

	GameStatus.define :CANCELLED, -1
	GameStatus.define :WAITING_FOR_PLAYERS, 1
	GameStatus.define :IN_PROGRESS, 2
	GameStatus.define :COMPLETED, 3
end
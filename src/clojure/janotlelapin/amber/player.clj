(ns janotlelapin.amber.player)

(set! *warn-on-reflection* true)

(def players (atom {}))

(defn get-players
  "Returns a vector containing each player id."
  [] (keys @players))

(defn get-player
  "Returns a player from its id.",
  [player-id] (get @players player-id))

(defn create-player
  "Adds a player from its id and game id."
  [game-id player-id]
  (swap! players assoc player-id {
    :game game-id
  }))

(defn update-player
  "Sets the value for the given player to be: (apply f current-value-of-player args)"
  [player-id f & args]
  (swap! players assoc player-id
    (apply f (get @players player-id) args)))

(defn delete-player
  "Deletes a player."
  [player-id] (swap! players dissoc player-id))

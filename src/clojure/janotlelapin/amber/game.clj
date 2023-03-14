(ns janotlelapin.amber.game)

(set! *warn-on-reflection* true)

(def games (atom {}))

(defn get-games
  "Returns a vector containing each game id."
  [] (keys @games))

(defn get-game
  "Returns a game from its id."
  [game-id] (get @games game-id))

(defn game-running?
  "Returns whether the given game has been started."
  [game] (> (get game :start) 0))

(defn game-time
  "Returns the time that elapsed since the game started, in milliseconds."
  [game]
  (if (game-running? game)
    (- (System/currentTimeMillis) (get game :start))
    -1))

(defn create-game
  "Adds a game with the given id, or a randomly generated UUID one if no argument is provided."
  ([id] (swap! games assoc id {:start -1
                               :players []}))
  ([] (create-game (java.util.UUID/randomUUID))))

(defn update-game
  "Sets the value for the given game to be: (apply f current-value-of-game args)"
  [game-id f & args]
  (swap! games assoc game-id
         (apply f (get @games game-id) args)))

(defn start-game
  "Effectively sets the game as running, should be called when the game starts."
  [game-id] (update-game game-id assoc :start (System/currentTimeMillis)))

(defn add-player
  "Adds the specified player id to the given game ids player list."
  [game-id player-id]
  (update-game
   game-id
   assoc
   :players
   (conj (get-in @games [game-id :players]) player-id)))

(defn remove-player
  "Removes the specified player id to the given game ids player list."
  [game-id player-id]
  (update-game
   game-id
   assoc
   :players
   (vec (remove
         (fn [id] (= id player-id))
         (get-in @games [game-id :players])))))

(defn delete-game
  "Deletes a game."
  [game-id] (swap! games dissoc game-id))

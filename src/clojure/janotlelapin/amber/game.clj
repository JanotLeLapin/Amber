(ns janotlelapin.amber.game)

(set! *warn-on-reflection* true)

(def game (atom {:start 0}))

(defn game-running?
  "Returns whether the game has been started."
  [] (> (get @game :start) 0))

(defn game-time
  "Returns the time that elapsed since the game started, in milliseconds."
  []
  (if (game-running?)
    (- (System/currentTimeMillis) (get @game :start))
    -1))

(defn update-game
  "Sets the value for the game to be: (apply f current-value-of-game args)"
  [f & args]
  (reset! game (apply f @game args)))

(defn start-game
  "Effectively sets the game as running, should be called when the game starts."
  [] (update-game assoc :start (System/currentTimeMillis)))

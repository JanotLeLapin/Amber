(ns janotlelapin.amber
  (:require [clj-http.client :as client]))

(def url "http://localhost:4200")

(defn create-game
  "Creates a new game and returns its id."
  []
  (get (client/post (str url "/games")) :body))

(defn get-games
  "Returns a vector containing each game id."
  []
  (get (client/get (str url "/games") {:as :json}) :body))

(defn get-game-time
  "Returns the time that elapsed since the game started in milliseconds."
  [game]
  (Integer/parseInt (get (client/get (str url "/games/" game "/time")) :body)))

(defn start-game
  "Effectively sets the game as running, should be called when the game starts."
  [game]
  (client/patch (str url "/games/" game "/time"))
  nil)

(defn delete-game
  "Deletes the game, and every player in the game."
  [game]
  (client/delete (str url "/games/" game))
  nil)

(defn add-player
  "Adds a player with the specified identifier to the game."
  [game player]
  (client/post (str url "/games/" game "/players") {:body player})
  nil)

(defn get-players
  "Returns every player from the given game."
  [game]
  (get (client/get (str url "/games/" game "/players") {:as :json}) :body))

(defn get-player
  [game player k]
  (get (get (client/get (str url "/games/" game "/players/" player "/" k) {:as :json}) :body) :v))

(defn update-player
  "Updates the player with the given map."
  [game player k v]
  (client/put (str url "/games/" game "/players/" player "/" k)
              {:form-params {:v v}
               :content-type :json})
  nil)

(defn delete-player
  "Removes the player from the game."
  [game player]
  (client/delete (str url "/games/" game "/players/" player))
  nil)
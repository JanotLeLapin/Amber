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
  [^str game]
  (Integer/parseInt (get (client/get (str url "/games/" game "/time")) :body)))

(defn start-game
  "Effectively sets the game as running, should be called when the game starts."
  [^str game]
  (client/patch (str url "/games/" game "/start"))
  nil)

(defn delete-game
  "Deletes the game, and every player in the game."
  [^str game]
  (client/delete (str url "/games/" game))
  nil)

(defn add-player
  "Adds a player with the specified identifier to the game."
  [^str game ^str player]
  (client/post (str url "/games/" game "/players/" player))
  nil)

(defn get-players
  "Returns every player from the given game."
  [game]
  (get (client/get (str url "/games/" game "/players") {:as :json}) :body))

(defn update-player
  "Updates the player with the given map."
  [game player data]
  (client/put (str url "/games/" game "/players/" player)
              {:content-type :json
               :form-params data})
  nil)

(defn update-player-meta
  "Updates the player metadata with the given map."
  [game player data]
  (client/put (str url "/games/" game "/players/" player "/meta")
              {:content-type :json
               :form-params data})
  nil)

(defn delete-player
  "Removes the player from the game."
  [game player]
  (client/delete (str url "/games/" game "/players/" player))
  nil)
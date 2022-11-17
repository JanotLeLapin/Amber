(ns janotlelapin.amber
  (:require [clj-http.client :as client]))

(def url "http://localhost:4200")

(defn create-game []
  (get (client/post (str url "/games")) :body))

(defn get-games []
  (get (client/get (str url "/games") {:as :json}) :body))

(defn get-game-time [game]
  (Integer/parseInt (get (client/get (str url "/games/" game "/time")) :body)))

(defn start-game [game]
  (client/patch (str url "/games/" game "/start"))
  nil)

(defn delete-game [game]
  (client/delete (str url "/games/" game))
  nil)

(defn add-player [game player]
  (client/post (str url "/games/" game "/players/" player))
  nil)

(defn get-players [game]
  (get (client/get (str url "/games/" game "/players") {:as :json}) :body))

(defn update-player [game player data]
  (client/put (str url "/games/" game "/players/" player)
              {:content-type :json
               :form-params data})
  nil)

(defn update-player-meta [game player data]
  (client/put (str url "/games/" game "/players/" player "/meta")
              {:content-type :json
               :form-params data})
  nil)

(defn delete-player [game player]
  (client/delete (str url "/games/" game "/players/" player))
  nil)
(defproject amber "1.0.0"
  :description "Amber client written in Clojure"
  :url "http://example.com/FIXME"
  :license {:name "GPL-3.0"
            :url "https://www.gnu.org/licenses/gpl-3.0"}
  :plugins [[lein-cljfmt "0.9.2"]]
  :dependencies [[org.clojure/clojure "1.10.1"],
                 [org.clojure/data.json "2.4.0"],
                 [org.clj-commons/clj-http-lite "1.0.13"]]
  :source-paths ["src/clojure"]
  :java-source-paths ["src/java"]
  :repl-options {:init-ns janotlelapin.amber.game}
  :aot :all)
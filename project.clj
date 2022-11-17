(defproject amber "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "GPL-3.0"
            :url "https://www.gnu.org/licenses/gpl-3.0"}
  :dependencies [[org.clojure/clojure "1.10.1"],
                 [cheshire "5.11.0"],
                 [clj-http "3.12.3"]]
  :source-paths ["src/clojure"]
  :java-source-paths ["src/java"]
  :repl-options {:init-ns janotlelapin.amber}
  :aot :all)
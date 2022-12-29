# Amber

A minimalist yet opinionated library for writing Minecraft mini-game plugins in Clojure.

## Introduction

Writing a mini-game for Minecraft often involves storing and handling a lot of metadata for both players and games. Amber provides a high-performance server written in Elixir that contains this metadata, and a minimalist library written in Clojure to communicate with the server through the HTTP protocol.
For you the developper, this means two things:

1. You have a nice separation of concerns.
2. You can easily debug your plugin by simply looking up the metadata from your browser.

## Why Clojure?

This is where the opinionated part comes in: I believe the problem of storing metadata and accessing it regularly cannot be solved with an object-oriented abstraction, and trying to do so will either lead to performance issues, or an unusable and absurdly complex library.
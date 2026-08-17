# ChatGPT Build Control

This repository includes a small GitHub Actions control workflow that can dispatch the existing `4. Build Trio` workflow for either `dev` or `main` when an authorized command is posted to the dedicated control issue.

Accepted commands:

- `/build dev`
- `/build main`

Only comments posted by the GitHub user `Frankydude` on the designated control issue are accepted.

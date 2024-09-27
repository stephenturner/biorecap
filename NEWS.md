# biorecap 0.2.1

- Added a `host` argument to `biorecap_report()` and `add_summary()` that gets passed to `ollamar::generate()`, allowing the user to choose the host for ollama. By default, `host=NULL` uses ollama's default base URL (using the local ollama server). This can be used to connect to a llama server running remotely or within a firewalled network (fixes #7).
- Fixed list of medRxiv subjects (see `?subjects`).
- Fixed an issue with `get_preprints()` where a valid subject has no preprints associated with it at all.
- Updated tests.

# biorecap 0.2.0

- Added medRxiv support. The `get_preprints()` function will now pull from either the bioRxiv or medRxiv RSS feed depending on the subject passed to it. All downstream functions and reporting updated to reflect this change (fixes #5).
- Changed default model to llama 3.2 3B.
- Added new source column for the returned preprints indicating whether the preprint came from bioRxiv or medRxiv.
- Updated tests.

# biorecap 0.1.1

- Fix bug in `add_summary()` caused by upstream changes in ollamar (fixes #1).
- Bumped minimum required version of ollamar to 1.2.1.

# biorecap 0.1.0

- Initial release.

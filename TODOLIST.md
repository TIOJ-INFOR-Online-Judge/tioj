## Current

- [x] Remove `problem_type` & add `specjudge_type`, `specjudge_lang`, `interlib_type`
- [x] Add problem banned compiler
- [x] Rails 6
- [x] Refactor some integer DB fields to enum (e.g. problem type)
- [x] Change post to optional polymorphism & allow post for problems
    - types: normal / issue / solution (reimplement PR #10); issue will also appear in global posts for admins
    - control discussion / view solution independently
- [x] Add RSS & VSS on limits & results / change to us precision on td
- [x] Add priority at new fetch API
- [x] Add interlib implementation
- [x] Move announcement to database
- [x] Add description about RSS & VSS and move them to /about
- [x] Move current result to old & rejudge all submissions into new result
- [x] Add score precision to problem
- [x] Provide Dockerfile / install script (PR #6) & update README (after tioj-judge finished)
    - Deprecate tioj-docker; test in VMs
- [x] Add reject API for fetching
- [x] ActionCable for submission notifying
    - [x] Add judge client online status
    - [x] Move most of the fetch code (except testdata download) to channel
    - [ ] Update Dockerfile & fix install script (systemd)
- [x] Multistage problems & strict mode
- [x] Testdata message (collapsable row)

## Enhance features & PRs

- [x] Testdata rearrange & batch modify (issue #5)
    - fields for limits & position
    - checkbox for "same as above" & shortcut for check/uncheck all
    - don't change problem tasks
- [x] Option to ignore some testdata in overall verdict
- [x] PR #3 (issue #1)
- [x] PR #4 (issue #2)
- [x] PR #11 (use MIN(id) to MAX(id))
- [x] PR #12
- [x] PR #13 (cherry-pick: `271eaed`, `bcfc6ac`, `ba5967c`; reimplement: `719b4d6`)
- [x] Precise timestamp (for testdata fetching)

## Future

- [ ] Add option to stop on first non-AC testdata of each task (score = 0 if unfinished)
- [ ] Pin
- [ ] Enhance posts UI
- [ ] Upload submission by file + non-UTF-8 code
- [ ] I/O interactive & output-only problems
- [ ] Batch upload testdata
- [ ] Add more languages
- [ ] IOI-style scoring in contest (max of each subtask)
- [ ] Judge load balancing
- [ ] Write basic tests
- [ ] Send compiler information from judge server
- [ ] Per-language memory/time limit
- [ ] Contest-only users + batch creation
    - don't appear in rank, can only submit to contests
- [ ] Role for problem setter
    - can add problem, edit/rejudge their own problems and manage submissions in them, but nothing else
- [ ] Teaming in contest
- [ ] Post voting & contribution system
- [ ] Notification system for problem issue reporting
- [ ] Problem import & export

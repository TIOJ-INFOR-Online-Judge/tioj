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
- [ ] Add interlib implementation
- [ ] Move current result to old & rejudge all submissions into new result
- [ ] Provide Dockerfile / install script (PR #6) & update README (after tioj-judge finished)
    - also update tioj-docker & test in VMs
- [ ] Move announcement to database

## Enhance features & PRs

- [ ] Testdata rearrange & batch modify
    - fields for limits & position
    - checkbox for "same as above" & shortcut for check/uncheck all
    - don't change problem tasks
- [ ] Enhance posts UI
- [ ] PR #3 (issue #1)
- [ ] PR #4 (issue #2)
- [ ] PR #11 (use MIN(id) to MAX(id))
- [ ] PR #12
- [ ] PR #13 (cherry-pick: `271eaed`, `bcfc6ac`, `ba5967c`; reimplement: `719b4d6`)

## Future

- [ ] Stop on first non-AC testdata of each task (score = 0 if unfinished)
- [ ] Upload submission by file
- [ ] Add more languages
- [ ] Write basic tests
- [ ] Contest-only users + batch creation
    - don't appear in rank, can only submit to contests
- [ ] Role for problem setter
    - can add problem, edit/rejudge their own problems and manage submissions in them, but nothing else
- [ ] Teaming in contest
- [ ] Post voting & contribution system
- [ ] Notification system for problem issue reporting
- [ ] Problem import & export

# Security Policy

## Reporting a vulnerability

Please do not report security vulnerabilities through public GitHub issues,
pull requests, or discussions. Use [GitHub's private vulnerability reporting feature](https://github.com/TIOJ-INFOR-Online-Judge/tioj/security/advisories/new) for this repository.

Please include, where possible:

- a description of the vulnerability and its potential impact;
- the affected component, route, or configuration;
- clear reproduction steps or a proof of concept;
- affected versions or commit hashes; and
- any suggested mitigation.

## Supported versions

Only the **latest TIOJ release** receives security fixes. Users running an older
version should upgrade before reporting issues where possible.

## Security best practices

- Do not commit `.env` files, `settings.yml` or `database.yml` configuration files
  containing passwords, API keys, database credentials, SMTP credentials,
  `TIOJ_KEY`, Rails credentials, or other secrets. Keep these values in the
  deployment environment or a secret manager. Only commit example files with
  placeholder values.
- Change or remove the default administrator credentials (`admin`) immediately
  after installation.
- Treat every TIOJ administrator account as highly privileged. An
  administrator can manage problems, test data, submissions, and judge-server
  settings. Problem descriptions and some other pages intentionally allow
  administrators to edit HTML and other flexible content. As a result, a
  compromised administrator account could inject malicious content into the
  site, affect visitors, or make a judge execute administrator-controlled
  judging or special-judge code. Grant administrator access only to trusted
  operators and review these changes carefully.
- Serve TIOJ exclusively over HTTPS in production. Configure TLS at the
  application or reverse-proxy layer and ensure that session cookies are sent
  securely.
- Keep judge servers, the TIOJ application, and the database on a restricted
  network. Do not expose the database to the public internet. Configure each
  judge-server key as a long, randomly generated secret, and never expose or
  commit these keys to the repository.
- Back up the production database regularly, protect backups with encryption
  and access controls, and verify that they can be restored when needed.
- Follow the [TIOJ upgrade instructions](https://github.com/TIOJ-INFOR-Online-Judge/tioj/wiki/Upgrade)
  and release notes. Keep Ruby, Rails, Node.js, Yarn, Nginx, `tioj-judge`, and other
  application and deployment dependencies within their supported versions.
  When instructed, upgrade and rebuild `tioj-judge` together with TIOJ, using
  a version combination listed as compatible in the release notes.

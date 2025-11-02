## 2.9.1

- docs: enhance README with engaging descriptions in [e9e503e](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/e9e503e)

## 2.9.0

- feat: ability to provide a custom connectivity check function in [e04ab72](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/e04ab72)
- chore: updated example app to flutter v3.35 in [d451fea](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/d451fea)
- docs: improved over-all documentation in [205cd9a](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/205cd9a)

## 2.8.0

- feat: updated [connectivity_plus](https://pub.dev/packages/connectivity_plus) dependency to v7.0.0 in [d8cf04d](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/d8cf04d)
- docs: added information about `enableStrictCheck` usage in [6fb7ed6](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/6fb7ed6)

## 2.7.2

- fix: some URIs consistently failing in [df4461c](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/df4461c)
- fix: type cast error when network changes in [3d6b56e](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/3d6b56e)
- docs: updated tested uris in [04f63cf](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/04f63cf)

## 2.7.1

- Fixed Apple Privacy Manifest File Problem in [c1e65d2](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/c1e65d2). Thanks [SalihCanBinboga](https://github.com/SalihCanBinboga) for [#72](https://github.com/OutdatedGuy/internet_connection_checker_plus/pull/72)
- chore: updated example app to flutter v3.29 in [db3c812](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/db3c812)

## 2.7.0

- feat: flag `enableStrictCheck` to require all addresses to return success in [9edc61b](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/9edc61b)

## 2.6.0

- feat: function to change check interval duration and reset timer in [6a4ef67](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/6a4ef67). Thanks [GenixPL](https://github.com/GenixPL) for [#63](https://github.com/OutdatedGuy/internet_connection_checker_plus/pull/63)
- chore: updated example app to flutter v3.27 in [30c8b15](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/30c8b15)

## 2.5.2

- refactor: removed unnecessary `compute` function in [33e1a55](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/33e1a55)
- chore: updated example app to Flutter 3.24 template in [93071f9](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/93071f9)
- docs: added instructions to pause internet checking when app goes to backgroud in [071dcf6](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/071dcf6)

## 2.5.1

- refactor: lowered sdk constraints to support dart 2.15 and above in [c78ef26](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/c78ef26)

## 2.5.0

- feat: use cloudflare domain for faster checks in [ffc4e84](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/ffc4e84)
- refactor: increased check interval to 10s in [2c02ba3](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/2c02ba3)
- docs: updated the tested URIs for the newer version in [6ae97e6](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/6ae97e6)

## 2.4.2

- docs: updated the default urls used for connection check in [d66ff76](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/d66ff76)

## 2.4.1

- fix(web): dart isolates not working on web platform in [fa57142](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/fa57142)

## 2.4.0

- perf: using isolates for http requests in [826a9b0](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/826a9b0)
- perf: updated default uri to use 4x less data in [3fa1ed8](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/3fa1ed8)
- chore: updated example app to Flutter 3.22 template in [a5ae1f9](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/a5ae1f9)

## 2.3.0

- chore!: updated [connectivity_plus](https://pub.dev/packages/connectivity_plus) dependency to v6.0.1 in [d2d9019](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/d2d9019)

## 2.2.0

- feat: added custom headers and success criteria function in [acec1e6](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/acec1e6). Thanks [@tatashidayat](https://github.com/tatashidayat) for [#18](https://github.com/OutdatedGuy/internet_connection_checker_plus/pull/18)
- docs: updated example app with new features in [aff81b8](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/aff81b8)

## 2.1.0

- chore!: updated [connectivity_plus](https://pub.dev/packages/connectivity_plus) dependency to v5.0.0 in [99c8726](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/99c8726)

## 2.0.0

> ### Contains Breaking Changes

- feat!: changed working logic by using `http` requests instead of `Socket` connections.
- chore: updated example app to Flutter 3.10 template.
- legal: updated licenses and added credits.
- docs: updated readme to contains new working logic.

## 1.0.1

- Updated Readme

## 1.0.0

- **BREAKING CHANGES**

  - Using `http` requests instead of `Socket` connections.
  - Replaced `InternetAddress` with `Uri`.

- **NEW FEATURES**

  - Added **_proper_** `Web` support.
  - Faster connection checks.
  - Reduced latency.

## 0.0.1

- Initial Release
- Cloned from [internet_connection_checker](https://github.com/RounakTadvi/internet_connection_checker)
- Added Web Support

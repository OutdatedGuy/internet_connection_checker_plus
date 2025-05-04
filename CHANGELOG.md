## 2.7.2

- fix: some URIs consistently failing in [df4461c](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/df4461ce7fa16f014fb5a998578dfd263197baeb)
- fix: type cast error when network changes in [3d6b56e](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/3d6b56e9b80a0e471138e9b50316fcf4228da6d2)
- docs: updated tested uris in [04f63cf](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/04f63cfa58a976fab901f81ccb56543790eaec01)

## 2.7.1

- Fixed Apple Privacy Manifest File Problem in [c1e65d2](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/c1e65d271bec0e42475f1786fee364ddefce8cb7). Thanks [SalihCanBinboga](https://github.com/SalihCanBinboga) for [#72](https://github.com/OutdatedGuy/internet_connection_checker_plus/pull/72)
- chore: updated example app to flutter v3.29 in [db3c812](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/db3c81245b3db41c3074abfac2c7f9d8ecd43959)

## 2.7.0

- feat: flag `enableStrictCheck` to require all addresses to return success in [9edc61b](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/9edc61b2b3e6659b06328cf91efcc0218deef314)

## 2.6.0

- feat: function to change check interval duration and reset timer in [6a4ef67](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/6a4ef67a3810e65759a6b32b14901150785ca488). Thanks [GenixPL](https://github.com/GenixPL) for [#63](https://github.com/OutdatedGuy/internet_connection_checker_plus/pull/63)
- chore: updated example app to flutter v3.27 in [30c8b15](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/30c8b1553bcff2bb62ad6c62abebefb15a0d5cb4)

## 2.5.2

- refactor: removed unnecessary `compute` function in [33e1a55](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/33e1a55743ac6924d31300913991ecc3b3ba85a3)
- chore: updated example app to Flutter 3.24 template in [93071f9](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/93071f9f444a0d11c8760d63fb8b6c52432baa2d)
- docs: added instructions to pause internet checking when app goes to backgroud in [071dcf6](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/071dcf6f278218795b72a582350dbed15132024d)

## 2.5.1

- refactor: lowered sdk constraints to support dart 2.15 and above in [c78ef26](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/c78ef2638bc9d18f284c0d307377a4b30102b253)

## 2.5.0

- feat: use cloudflare domain for faster checks in [ffc4e84](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/ffc4e84a45eb3b72d2db6ef24b20363dec612647)
- refactor: increased check interval to 10s in [2c02ba3](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/2c02ba3620c044c441cd1996dfdcf080e22e3d07)
- docs: updated the tested URIs for the newer version in [6ae97e6](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/6ae97e68ecd666e29873804d2effc1485d0e8bfc)

## 2.4.2

- docs: updated the default urls used for connection check in [d66ff76](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/d66ff768e6a1722f32e044412391ffa488afeee2)

## 2.4.1

- fix(web): dart isolates not working on web platform in [fa57142](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/fa571420061af109fc85c4150825b19645fe8b1a)

## 2.4.0

- perf: using isolates for http requests in [826a9b0](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/826a9b069896073ee69d5dcfb21d1a027ebaf876)
- perf: updated default uri to use 4x less data in [3fa1ed8](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/3fa1ed8ddcfae5122a2cb51b42ae67ae1f8df028)
- chore: updated example app to Flutter 3.22 template in [a5ae1f9](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/a5ae1f999420caca9f7538a95c727f84c309b59c)

## 2.3.0

- chore!: updated [connectivity_plus](https://pub.dev/packages/connectivity_plus) dependency to v6.0.1 in [d2d9019](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/d2d9019dc1cf317ba25a29e9f72c991828c86869)

## 2.2.0

- feat: added custom headers and success criteria function in [acec1e6](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/acec1e65c14510d4cb05e9f7b73e8b7972b271d8). Thanks [@tatashidayat](https://github.com/tatashidayat) for [#18](https://github.com/OutdatedGuy/internet_connection_checker_plus/pull/18)
- docs: updated example app with new features in [aff81b8](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/aff81b81ff8e4c51cddd06af6956ac5e9a0af085)

## 2.1.0

- chore!: updated [connectivity_plus](https://pub.dev/packages/connectivity_plus) dependency to v5.0.0 in [99c8726](https://github.com/OutdatedGuy/internet_connection_checker_plus/commit/99c87262b0aefbd53aaab03f707cd7800471c8f6)

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

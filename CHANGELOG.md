## [0.1.6] - 2023-11-09

Fix a bug when N+1 is caused not in the request (e.g. Sidekiq) [51f051e](https://github.com/makicamel/bulletmark_repairer/commit/51f051e608b84b7da96ac879a324ed438c14eeeb)

## [0.1.5] - 2023-10-27

Be able to patch for nested associations require `includes` though child associations are already included [d1b7445](https://github.com/makicamel/bulletmark_repairer/commit/d1b7445556c20bc037beb6a013ac70531426a7ea)

## [0.1.4] - 2023-10-22

- Patch files other than controllers [218566d](https://github.com/makicamel/bulletmark_repairer/commit/218566d1531751f204941c3dcff7f095a056d39f)
- Patch unassigned queries [159573a](https://github.com/makicamel/bulletmark_repairer/commit/159573ada036ee3ee39428b1e59066934b676c02)
- Apply patches starting from the top of the method [f8d0058](https://github.com/makicamel/bulletmark_repairer/commit/f8d00582a5b3b084c0a35a54726396a2a063f8dd)
- Log also when the target file is in the skip list [a23a3bc](https://github.com/makicamel/bulletmark_repairer/commit/a23a3bc0edf1e94d3aa6ea95449c9570b9322d65)

## [0.1.3] - 2023-10-18

- Fix a redundant auto-correct for multiple tests with n+1 queries when running RSpec [#6](https://github.com/makicamel/bulletmark_repairer/pull/6) ([@ydah])

## [0.1.2] - 2023-10-16

- Reduce dependencies [#1](https://github.com/makicamel/bulletmark_repairer/pull/1) ([@tricknotes])
- Stop using class instance variables for thread safe [024f6c5](https://github.com/makicamel/bulletmark_repairer/commit/024f6c53f82b182a998c1e43de48d8c6c9ce5bf3)

## [0.1.1] - 2023-10-11

- Support Ruby 3.0 [dbdf27c](https://github.com/makicamel/bulletmark_repairer/commit/dbdf27c6c9a7259ad9474153d2394da5bac45b43)

## [0.1.0] - 2023-10-10

- Initial release

[@tricknotes]: https://github.com/tricknotes
[@ydah]: https://github.com/ydah

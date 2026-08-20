# proofcheck

proofcheck is a verifier for first-order refutation proofs written in the
TPTP/TSTP format. Given a proof, it checks every inference step
independently and reports exactly one of:

```
% SZS status VerifiedGood     the proof is valid
% SZS status VerifiedBad      the proof is flawed
% SZS status Unknown          a step could not be decided
% SZS status Timeout          the time limit was reached
```

This repository is the special source-only release of proofcheck 2.0. No
pre-built binaries are provided here; you build proofcheck yourself from
the source in this repository.

## Building

Requires CMake 3.14+ and a C++17 compiler.

```
git clone https://github.com/AlgorithmicTruth/proofcheck-releases.git
cd proofcheck-releases
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make
```

## Backend tools (not bundled)

proofcheck invokes four external theorem provers/model finders as
separate processes at runtime. None of them are distributed here --
obtain each directly from its own project:

| Tool | Required? | Source |
|---|---|---|
| E prover (`eprover`) | mandatory | https://github.com/eprover/eprover |
| Mace4 | mandatory | https://prover9.org |
| Prover9 | mandatory | https://prover9.org |
| Vampire | mandatory | https://github.com/vprover/vampire |

proofcheck auto-discovers these tools in this order: co-located with the
proofcheck binary, then the current directory, then your `PATH`. All four
are mandatory -- proofcheck exits with a fatal error at startup if any
of them is missing.

## Usage

```
proofcheck [-j N] [-t T] [-T T] [-e CMD] -p <problem.p> <proof>
proofcheck [-j N] [-t T] [-e CMD] -p <problem.p> -m <model_output>
proofcheck [-j N] [-t T] [-e CMD] <model.agmv | model.out>
```

| Flag | Description | Default |
|------|-------------|---------|
| `-p FILE` | TPTP problem file (required for proof verification; `include()` resolved) | - |
| `-j N` | Number of parallel ATP workers | 8 |
| `-t T` | Per-step ATP timeout in seconds | 3 |
| `-T T` | Total wall-clock timeout in seconds | (off) |
| `-e CMD` | eprover binary path | auto-discover |
| `-a` | High assurance: cross-check failed model steps with ATP | off |
| `-aa` | Full assurance: cross-check all model steps with ATP | off |
| `-self-certify` | Run the embedded self-test suite | - |

### Verify the installation

```
./proofcheck -self-certify
```

## License

proofcheck is Copyright (c) 2026 Jeffrey Machado and Larry Lesyna and is
licensed under the Proofcheck 2.0 Source-Available License (see
`LICENSE` in this repository). The source distributed here may be
compiled and used, including for commercial purposes, and the resulting
unmodified binaries and this source may be redistributed non-commercially.
Modified copies may not be distributed. See `LICENSE` for the full terms.

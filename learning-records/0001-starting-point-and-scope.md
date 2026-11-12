# Starting point and scope

The learner is comfortable with Rust, has some protobuf 2 familiarity, and is new to `prost`. The goal is safe evolution of protobuf models in Rust; `prost` is required, while `tonic` and gRPC are intentionally out of scope.

## Implications

Start with wire compatibility and schema evolution, then connect those rules to generated Rust types. Do not spend lesson time on Rust basics or RPC.

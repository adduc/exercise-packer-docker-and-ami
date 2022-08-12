## Goal

Build an AMI and Docker image using the same packer and/or build config

## Why?

When building images through Packer, the time to build and test AMIs is
longer than I consider acceptable for iterating on ideas. I'd like to
be able to build docker images through Packer during development, and
use the same config file to build AMIs when I'm ready to test in an AWS
environment.

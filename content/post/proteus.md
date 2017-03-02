---
author: erizocosmico
date: 2017-02-27
title: "Proteus, keeping Go as the source of truth"
description: "We are releasing proteus, a tool to generate protobuf files taking Go as the source of truth instead of the other way around."
categories: ["technical"]
---

## Introduction

At source{d} we've been using Go for almost two years. Until machine learning came along, Go was the only language in which we needed to use our data models. Right now, Python is playing a bigger role in our platform and Scala is joining as another player. With that in mind, we need to start thinking how to effectively and efficiently share our data models across all those languages, and others, in case we would start using more.

We chose [Protocol Buffers](https://developers.google.com/protocol-buffers/) as the serialization format for this exchange of data. Usually, people create their `.proto` files where they define their models, enumerations, services and so on, and then the models in each specific language are generated from those `.proto` files.

There is a critical problem with that approach for us: **the generated code is not idiomatic** for the supported languages (take a look at the Python code generated from any proto file and you will understand why).

Instead of following this approach, we've thought of something different: choose the language with the biggest role in our codebase and use it as the source of truth. That way, at least one of the languages has idiomatic models and code. The most "important" language for us is apparently Go.

## Proteus

Hence we started working on [proteus](https://github.com/src-d/proteus), a tool that scans Go packages and generates `.proto` files from them.

**How does it work?**

* Scans all structs that have the comment `//proteus:generate` and generates them as protobuf messages.
* Scans all the type definitions with the comment `//proteus:generate` and their constant values and transforms them into proper protobuf enumerations.
* Resolves the types and ignores those which it can't.
* Converts them to protobuf structures and writes the `.proto` files.

So, imagine you've got the following code:

```go
package models

import "time"

type Model struct {
        ID        int64
        CreatedAt time.Time
}

//proteus:generate
type User struct {
        Model
        Status             Status
        Username           string
        Password           string
        NotCryptedPassword string `proteus:"-"`
}

//proteus:generate
type Status int

const (
        Pending  Status = iota
        Active
        Inactive
)
```

This code corresponds to the following protobuf file:

```proto
syntax = "proto3";
package models;

import "google/protobuf/timestamp.proto";

option go_package = "models";

message User {
        option (gogoproto.typedecl) = false;
        int64 id = 1 [(gogoproto.customname) = "ID"];
        google.protobuf.Timestamp created_at = 2 [(gogoproto.nullable) = false, (gogoproto.stdtime) = true];
        models.Status status = 3;
        string username = 4;
        string password = 5;
}

enum Status {
        option (gogoproto.enumdecl) = false;
        option (gogoproto.goproto_enum_prefix) = false;
        PENDING = 0 [(gogoproto.enumvalue_customname) = "Pending"];
        ACTIVE = 1 [(gogoproto.enumvalue_customname) = "Active"];
        INACTIVE = 2 [(gogoproto.enumvalue_customname) = "Inactive"];
}
```

You can check for more detailed examples in the [examples folder](https://github.com/src-d/proteus/tree/master/example).

## gRPC service generation

Methods and functions with the comment `//proteus:generate` will be exported as the gRPC service. Those methods and functions will be `rpc`s in the service. Proteus also generates the implementation of the server that satisfies the interface defined by protobuf for that service.

For the reference, the complete proteus' generation pipeline consists of three steps:

* Generate the `.proto` file from your Go source code.
* Use `protoc` and `gogo/protobuf` to generate the missing protobuf-related bits for your Go source code (marshal, unmarshal, etc) as well as defining a client and a server interface for your RPC services. Note that `gogo/protobuf` and `protoc` **do not** generate an implementation for the RPC service server.
* Generate the implementation of the RPC service server using some conventions to actually make this possible.

Imagine the following code:

```go
package user

//proteus:generate
func (s *UserStore) GetByID(id uint64) (*User, error) {
        // implementation
}
```

It would generate the following protobuf source:

```proto
service UserService {
        rpc UserStore_GetByID(UserStore_GetByIDRequest) returns (User);
}
```

Which would generate the following implementation:


```go
type userServiceServer struct {
}

func NewUserServiceServer() *userServiceServer {
        return &userServiceServer{}
}

func (s *userServiceServer) UserStore_GetByID(ctx context.Context, in *UserStore_GetByIDRequest) (result *User, err error) {
        result, err = s.UserStore.GetByID(in.Arg1)
        return
}
```

The above code obviously does not work. But it's impossible for proteus to know how to find the instance of `UserStore` to invoke the method `GetByID`, that's why the convention is to look for a field in the `userServiceServer` struct with the same name as the receiver type of the method. proteus is only capable of generating the stubs, but if you provide the implementation, our tool will use it instead.

```go
type userServiceServer struct {
        *UserStore
}

func NewUserServiceServer() *userServiceServer {
        return &userServiceServer{NewUserStore()}
}
```

If we implement the type ourselves, the generated code will be just the method, and `UserStore_GetByID` would be able to get the instance of `UserStore` to call the method on, making everything work as expected.

## Integration with `gogo/protobuf`

Because the whole generation process consists of three steps, as explained in the previous section, proteus has a shorthand to run all in one single command directly built into the proteus binary.

```
proteus -p my/go/package 
        -p my/other/go/package 
        -f path/to/my/protos/folder
        --verbose
```

This command generates the protos from your Go source code, the marshaling/unmarshaling for your structs and the implementation of your RPC services without the need to look at any protobuf code.

We need two dependencies installed for this command to work:

* [`protoc`](https://github.com/google/protobuf) command
* `go get github.com/gogo/protobuf/...`

## Why not drop the need for `gogo/protobuf`?

`gogo/protobuf` works in the other, completely different domain. While `gogo/protobuf` proceeds through `Proto -> Go`, proteus works in the opposite direction.

The only thing we are adding with proteus is what we think is missing: keeping Go as the source of truth for messages, enumerations and services.

Indeed, it introduces two steps instead of just one. But it brings several advantages.

## Conclusion

We are trying to keep Go as the source of truth.

* We want to use our code ourselves, totally abstracted from protobuf.
* We don't want to write by ourselves the gRPC server that satisfies the generated interface.

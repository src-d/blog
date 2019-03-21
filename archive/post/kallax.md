---
author: erizocosmico
date: 2017-04-19
title: "Kallax: Why we built yet another ORM for Go"
description: "We are releasing the first stable version of Kallax, our typesafe, fast PostgreSQL ORM with support for JSON operators, arrays and slices."
image: /post/kallax/kallax.png
categories: ["technical", "go", "orm"]
---

![Kallax logo](/post/kallax/kallax.png)

## What is kallax

[Kallax](https://github.com/src-d/go-kallax) is a PostgreSQL typesafe[^typesafe] ORM for the Go language.

Its aim is to provide a way of programmatically writing queries and interacting with a PostgreSQL database without having to write a single line of SQL, using strings to refer to columns or using values of wrong types in queries.

For that reason, **the first priority of kallax is to provide type safety to the data access layer**. Another goal of kallax is to make sure all models are, first and foremost, Go structs without having to use database-specific types such as, for example, sql.NullInt64. Support for arrays and slices of all basic Go types and all JSON and arrays operators is provided as well.

[^typesafe]: By typesafe we mean as typesafe as possible. There might be cases where the ORM is not 100% typesafe.

At this point, you will be wondering if kallax is named after the best-selling IKEA rack. And you will be right.

## The need for kallax

Go is a strongly typed language. Thus, it was strange to lose all that safety in a layer as important for us as the data layer. We designed kallax because we needed some of our necessities covered.

* **Avoid query failures because of typos**. `SELECT name FROM foo` and `SELECT nsme FROM foo` might look very similar but one will fail and no one will tell you until the query is run. You should have tests to check they work, but it's nicer if the compiler can tell you these kinds of things.
* Guarantee as much as possible that **queries have correct types**. `SELECT name FROM foo WHERE id = 'potato'` if you don't restrict that IDs to have only a certain type.
* Full support for querying JSON.
* Full support for Go arrays and slices. The [PostgreSQL driver](https://github.com/lib/pq) does not support arrays and it does not support slices of all Go basic types. Kallax, on the other hand, does.
* **Not needing special types for nullable types** (e.g. `sql.NullInt64`), which introduces specific types in your models only because the database layer needs them.
* **Fast queries**, even with one to one and one to many relationships.

The first of our needs alone almost rules out any other ORM for Go out there, as they typically access fields or where conditions using strings. 
The last one also rules out most of them, because if we wanted speed, we would have to use a lighter library and that would conflict even more with the first point.
Finally, no other ORM we've found saves you from using things like `sql.NullInt64`, which in the end ruled them all out.

So, after researching what was being used, we decided to build our own ORM. It may not be perfect, it may not suit everyone's needs, but it definitely suits ours. And that's why we're open sourcing it, in case someone else has these needs that, as far as we know, are not being covered yet.

## How can you make a typesafe ORM without generics?

The answer is, sadly, with **code generation**. Code generation can be hard to maintain, and we know it, but we think the benefits of this tool overcome the pain of using and maintaining generated code.

Since we use code generation, we can **avoid using reflection and being very fast**, compared to other ORMs that do use it. Of course, it will never be as fast as writing your plain SQL and scanning your models by hand, but it gives you all the benefits of an ORM without sacrificing performance too much.

Also because of that, we can avoid the need of using types like `sql.NullInt64` by just wrapping the basic Go types when they need to be nullable. For kallax, every pointer type can be nullable. So, instead of `sql.NullInt64` you'd use `*int64` and that would work automagically.

## Using kallax

A kallax model looks like the following.

```go
type User struct {
        kallax.Model        `table:"users"`
        ID        int64     `pk:"autoincr"`
        Username  string
        Email     string
        Password  string
        CreatedAt time.Time
}
```

If we add `//go:generate kallax gen` to a file in the package and then run `go generate` we will get a new `kallax.go` file with all the generated code for that model.

**What's in a `kallax.go` file?**

* A lot of internal stuff, mostly to deal with scanning and relationships.
* A `Store`, `Query` and `ResultSet` for every type (`UserStore`, `UserQuery` and `UserResultSet` in this case).
* `FindBy`s for all your struct fields as methods of your `Query`.
* `Schema` for your types.
* A constructor for your type.
* Documentation for all methods in the generated code.

So, let's use all that for our new model.

```go
store := NewUserStore(db) // it just needs an instance of *sql.DB

err := store.Insert(&User{
        Username: "john",
        Email: "john@doe.me",
        Password: crypt("1234bunnies"),
})
// remember to eat your vegetables and handle your errors

q := NewUserQuery().
        FindByUsername("john").
        FindByPassword(crypt("1234bunnies")).
        FindByCreatedAt(kallax.Gt, time.Now().Add(-30*24*time.Hour))

user, err := store.FindOne(q)
```

As you can see, **we already have a method in our query type to find by any of the struct fields**. Fields with types whose common operation is equality, accept just the value (matching the type of your struct field! yay for safety!), others, accept an operator as well. For example, look at the `FindByCreatedAt`, we gave it the operator we wanted to use and, the value that must match the type of the field as well.

Of course, we can make our own conditions by hand.

```go
q := NewUserQuery().
        Where(kallax.Like(Schema.User.Username, "john%")).
        Where(kallax.Lt(Schema.User.CreatedAt, time.Now().Add(-1 * time.Hour)))
```

Instead of using `"username"` to specify the column name we use the `Schema`, which is also generated.

The way to access a field in the schema is the same as accessing a field in a struct.

```
Schema.$ModelName.$FieldName.$AnotherField.$YetAnotherField...
```

If a field is a struct, you can access its properties from the field as well. That's used for querying JSON.

The right way to use the `Schema` and the operators is to add your custom `FindBy`s and then call them when using your queries. That way, all the conditions are in one place.

We can add our method directly in the same file where our model was defined.

```go
func (q *UserQuery) FindByUsernameLike(pattern string) *UserQuery {
        return q.Where(kallax.Like(Schema.User.Username, pattern))
}
```

**WARNING:** define these in your own model file, never on the `kallax.go`. You should never edit that file, as it will be nuked every time you regenerate your models.

## Dealing with relationships

Consider the following models. We have people who can have many pets, and a pet has an inverse relationship with its owner.
```go
type Person struct {
        kallax.Model `table:"people"`
        ID   int64   `pk:"autoincr"`
        Name string
        Pets []*Pet
}

type Pet struct {
        kallax.Model  `table:"pets"`
        ID    int64   `pk:"autoincr"`
        Name  string
        Kind  PetKind
        Owner *Person `fk:"owner_id,inverse"`
}

type PetKind byte

const (
        Cat PetKind = iota
        Dog
        Fish
)
```

On a sidenote, see the `PetKind` type? You'd think if you were using any other ORM, or plain SQL, you'd be able to use it. Truth is, you can't because it does not implement neither `sql.Scanner` nor `driver.Valuer`. Seems like a very silly thing, but it's a very common Go idiom to have such enum types. Since kallax generates code, it can wrap it and treat it as `byte` directly. So it's possible to use such types in kallax.

So, let's find some people and their pets.

```go
store := NewPersonStore(db)

q := NewPersonQuery().
        FindByName("Steven").
        WithPets(nil) // you can also pass a condition if you want pets filtered
person, err := store.FindOne(q)
```

Kallax generated methods on the query type to preload the relationships of the model with the form `With{RelationshipFieldName}`.
Note that relationships are **not** preloaded by default, they must be explicitly preloaded using such methods.
**WARNING:** preloading retrieves **all** the records of the relationship matching the giving condition, or just all of them if none was given. If the N side of your 1:N relationship is really large you may want to query from the other side.

### The N+1 problem

One of our goals was for kallax to be **as fast as possible** which is why the naive `N+1` solution for retrieving relationships did not work for us.

All 1:1 relationships are retrieved **in the same query** used to get the main models, using JOINs. So, retrieving pets with their owners would result in **no extra queries** (just a more expensive one, but still faster as a result).

One to many relationships are more complicated. The basic solution would be to retrieve a single model and then doing another query to retrieve all its relationships. But that is N+1 and we needed something better than that.

We solved that by doing **batching**. So we retrieve the main model in batches of N rows, then find the relationships of all these rows, merge them, and keep batching. For example, if the batches have a size of 50 (the default batch size, you can change it in the query with the `BatchSize` method) and we are retrieving 200 people. Instead of doing 201 queries, we only have to make 8. 4 for the 4 batches of people and 4 for retrieving the pets of all these batches. You might think this might be expensive, but the result is more than an order of magnitude faster than the other solution.

## Let's talk performance

We made benchmarks against [GORM](https://github.com/jinzhu/gorm) and plain `database/sql` to see if we accomplised our goal in terms of speed and memory usage. In the future we are planning to compare against more ORMs.

```
BenchmarkKallaxInsertWithRelationships-4         300       4767574 ns/op       19130 B/op        441 allocs/op
BenchmarkRawSQLInsertWithRelationships-4         300       4467652 ns/op        3997 B/op        114 allocs/op
BenchmarkGORMInsertWithRelationships-4           300       4813566 ns/op       34550 B/op        597 allocs/op

BenchmarkKallaxInsert-4                          500       3650913 ns/op        3569 B/op         85 allocs/op
BenchmarkRawSQLInsert-4                          500       3530908 ns/op         901 B/op         24 allocs/op
BenchmarkGORMInsert-4                            300       3716373 ns/op        4558 B/op        104 allocs/op

BenchmarkKallaxQueryRelationships/query-4       1000       1535928 ns/op       59335 B/op       1557 allocs/op
BenchmarkRawSQLQueryRelationships/query-4         30      44225743 ns/op      201288 B/op       6021 allocs/op
BenchmarkGORMQueryRelationships/query-4          300       4012112 ns/op     1068887 B/op      20827 allocs/op

BenchmarkKallaxQuery/query-4                    3000        433453 ns/op       50697 B/op       1893 allocs/op
BenchmarkRawSQLQuery/query-4                    5000        368947 ns/op       37392 B/op       1522 allocs/op
BenchmarkGORMQuery/query-4                      2000       1311137 ns/op      427308 B/op       7065 allocs/op
```

The results were surprising, the difference compared to `database/sql` was not as large as we expected, but the difference compared to GORM was huge querying and slightly better inserting. **The difference in memory usage, though, is really big**. Being this the first stable release of kallax, which has not been carefully optimized yet, we can say the results are very promising.

Of course, the benchmark is not really fair because kallax uses generated code, but in the end one of the things you care about your ORM is how fast it is and how many memory it uses, no matter what it does underneath.

## Next steps

There's still a long road ahead of us. Lots of performance improvements we can make, features to introduce, etc, but the ones that are closer in the roadmap might be the following.

* Automatically generate SQL schema from your models.
* Many to many relationships.
* Migrations.

## Conclusion

We've had quite the journey developing kallax. We had clear goals and we feel like they've been successfully achieved. Reinventing the wheel is, most of the time, not a good solution but in this case, we were covering a need that was there. This is not just another ORM, this is an ORM that cares for some specific needs.

We are pretty happy with the result and the first benchmark we've run, and we will definitely keep improving it in the future, since we are starting to use it in production, which guarantees bugs will get fixed and more features will get added.

You can read more about how to use kallax, its limitations, conventions, etc in the [README](https://github.com/src-d/go-kallax). If you find like some part of the documentation is missing, feel free to open an issue and we'll add some docs about it!

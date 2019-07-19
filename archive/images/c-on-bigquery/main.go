package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"
)

func main() {
	bs, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		log.Fatal(err)
	}
	b := new(strings.Builder)
	fmt.Fprint(b, bs[0])
	for _, c := range bs[1:] {
		fmt.Fprintf(b, ", %d", c)
	}

	fmt.Printf("const bytes = new Uint8Array([%s]);", b)
}

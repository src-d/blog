const fs = require('fs');

const memory = new WebAssembly.Memory({ initial: 256, maximum: 256 });
const env = {
    'abortStackOverflow': _ => { throw new Error('overflow'); },
    'table': new WebAssembly.Table({ initial: 0, maximum: 0, element: 'anyfunc' }),
    'tableBase': 0,
    'memory': memory,
    'memoryBase': 1024,
    'STACKTOP': 0,
    'STACK_MAX': memory.buffer.byteLength,
};
const imports = { env };

fs.readFile('sum.wasm', (err, bytes) => {
    WebAssembly.instantiate(bytes, imports).then(wa => {
        const exports = wa.instance.exports;
        const sum = exports._sum;
        console.log(sum(39, 3));
    });
});
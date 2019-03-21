function checkAssembly(row, emit) {
    emit({ b: WebAssembly != undefined });
}

bigquery.defineFunction(
    'checkAssembly',
    ['x'],
    [{ 'name': 'b', 'type': 'boolean' }],
    checkAssembly
);

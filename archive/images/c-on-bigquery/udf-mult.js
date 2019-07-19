function intdiv(row, emit) {
    emit({ d: row.x / row.y, m: row.x % row.y });
}

bigquery.defineFunction(
    'intdiv',
    ['x', 'y'],
    [{ 'name': 'd', 'type': 'integer' },
    { 'name': 'm', 'type': 'integer' }],
    intdiv
);

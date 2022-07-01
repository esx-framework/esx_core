type Query = string | number;
type Params = Record<string, unknown> | unknown[];
type Callback<T> = (result: T | null) => void;

type Transaction = {
  query: Query;
} & ({ parameters?: Params } | { values?: Params });

const Wait = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));
const assert = (condition: boolean, message: string) => {
  if (!condition) throw new TypeError(message);
};

const QueryStorage: string[] = [];

const safeArgs = (
  query: Transaction[] | string[] | Query,
  parameters?: Params,
  cb?: Callback<any>,
  transaction?: true
) => {
  if (typeof query === 'number') query = QueryStorage[query];

  if (transaction) assert(Array.isArray(query), `Transaction query expects an array, received ${typeof query}`);
  else assert(typeof query === 'string', `Query expects a string, received ${typeof query}`);

  if (parameters !== undefined)
    assert(
      typeof parameters === 'object' || Array.isArray(parameters),
      `Params expects object or array, received ${typeof parameters}`
    );

  if (cb !== undefined) assert(typeof cb === 'function', `Callback expects function, received ${typeof cb}`);

  return [query, parameters, cb];
};

function store(query: string) {
  assert(typeof query !== 'string', `Query expects a string, received ${typeof query}`);

  return QueryStorage.push(query);
}

function ready(callback: () => void) {
  setImmediate(() => {
    while (GetResourceState('oxmysql') !== 'started') Wait(50);
    callback();
  });
}

function query<T = any>(query: Query, parameters?: Params): Promise<T | null>;
function query<T = any>(query: Query, parameters?: Params, cb?: Callback<T>): void;
function query<T = any>(query: Query, parameters?: Params, cb?: Callback<T>): Promise<T | null> | void {
  if (cb) return exports.oxmysql.query(...safeArgs(query, parameters, cb));
  return exports.oxmysql.query_async(...safeArgs(query, parameters));
}

function single<T = Record<string | number, any>>(query: Query, parameters?: Params): Promise<T | null>;
function single<T = Record<string | number, any>>(query: Query, parameters?: Params, cb?: Callback<T>): void;
function single<T = Record<string | number, any>>(
  query: Query,
  parameters?: Params,
  cb?: Callback<T>
): Promise<T | null> | void {
  if (cb) return exports.oxmysql.single(...safeArgs(query, parameters, cb));
  return exports.oxmysql.single_async(...safeArgs(query, parameters));
}

function scalar<T = unknown>(query: Query, parameters?: Params): Promise<T | null>;
function scalar<T = unknown>(query: Query, parameters?: Params, cb?: Callback<T>): void;
function scalar<T = unknown>(query: Query, parameters?: Params, cb?: Callback<T>): Promise<T | null> | void {
  if (cb) return exports.oxmysql.scalar(...safeArgs(query, parameters, cb));
  return exports.oxmysql.scalar_async(...safeArgs(query, parameters));
}

function update(query: Query, parameters?: Params): Promise<number | null>;
function update(query: Query, parameters?: Params, cb?: Callback<number>): void;
function update(query: Query, parameters?: Params, cb?: Callback<number>): Promise<number | null> | void {
  if (cb) return exports.oxmysql.update(...safeArgs(query, parameters, cb));
  return exports.oxmysql.update_async(...safeArgs(query, parameters));
}

function insert(query: Query, parameters?: Params): Promise<number | null>;
function insert(query: Query, parameters?: Params, cb?: Callback<number>): void;
function insert(query: Query, parameters?: Params, cb?: Callback<number>): Promise<number | null> | void {
  if (cb) return exports.oxmysql.insert(...safeArgs(query, parameters, cb));
  return exports.oxmysql.insert_async(...safeArgs(query, parameters));
}

function prepare<T = unknown>(query: Query, parameters?: Params): Promise<T | null>;
function prepare<T = unknown>(query: Query, parameters?: Params, cb?: Callback<T>): void;
function prepare<T = unknown>(query: Query, parameters?: Params, cb?: Callback<T>): Promise<T | null> | void {
  if (cb) return exports.oxmysql.prepare(...safeArgs(query, parameters, cb));
  return exports.oxmysql.prepare_async(...safeArgs(query, parameters));
}

function transaction(query: Query, parameters?: Params): Promise<boolean>;
function transaction(query: Query, parameters?: Params, cb?: Callback<boolean>): void;
function transaction(query: Query, parameters?: Params, cb?: Callback<boolean>): Promise<boolean> | void {
  if (cb) return exports.oxmysql.transaction(...safeArgs(query, parameters, cb, true));
  return exports.oxmysql.transaction_async(...safeArgs(query, parameters, undefined, true));
}

export { store, query, single, scalar, update, insert, transaction, prepare, ready };
export default { store, query, single, scalar, update, insert, transaction, prepare, ready };

mod atoms;
mod mirage;

rustler::init! {
    "Elixir.Mirage.Native",
    [
        mirage::from_bytes,
        mirage::resize,
        mirage::overlay,
        mirage::write
    ],
    load = mirage::load
}

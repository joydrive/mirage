mod atoms;
mod mirage;

rustler::init! {
    "Elixir.Mirage.Native",
    [
        mirage::from_bytes,
        mirage::resize,
        mirage::resize_to_fill,
        mirage::overlay,
        mirage::write,
        mirage::empty,
        mirage::fill,
    ],
    load = mirage::load
}

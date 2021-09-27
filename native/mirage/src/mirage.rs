use image::{DynamicImage, FilterType, GenericImageView, ImageFormat};
use rustler::{Atom, Binary, Env, Error, NifResult, NifStruct, OwnedBinary, ResourceArc, Term};
use std::io::Write as _;

use crate::atoms::{gif, invalid_image, jpg, ok, png, unsupported_image_format};

#[derive(NifStruct)]
#[module = "Mirage.Image"]
pub struct MirageImage {
    byte_size: usize,
    format: Atom,
    height: u32,
    width: u32,
    resource: ResourceArc<Image>,
}

pub struct Image {
    image: DynamicImage,
    format: ImageFormat,
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn from_bytes(binary: Binary) -> NifResult<(Atom, MirageImage)> {
    let image = image::load_from_memory(binary.as_slice())
        .map_err(|_e| Error::Term(Box::new(invalid_image())))?;

    let format = image::guess_format(binary.as_slice())
        .map_err(|_e| Error::Term(Box::new(invalid_image())))?;

    let image = MirageImage {
        byte_size: binary.len(),
        format: image_format(format)?,
        width: image.width(),
        height: image.height(),
        resource: ResourceArc::new(Image { image, format }),
    };

    Ok((ok(), image))
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn resize(
    env: Env,
    resource: ResourceArc<Image>,
    width: u32,
    height: u32,
) -> Result<(Atom, Binary, MirageImage), Error> {
    let resized = resource
        .image
        .resize_to_fill(width, height, FilterType::Triangle);
    let mut output = Vec::new();
    let mut binary = OwnedBinary::new(resized.raw_pixels().len()).unwrap();

    match resized.write_to(&mut output, resource.format) {
        Ok(_) => {
            binary
                .as_mut_slice()
                .write_all(&output)
                .map_err(|_| Error::Atom("io_error"))?;
            let format = image_format(resource.format)?;
            let bytes = binary.release(env);
            let byte_size = bytes.as_slice().len();

            let mirage = MirageImage {
                byte_size,
                format,
                height,
                width,
                resource,
            };

            Ok((ok(), bytes, mirage))
        }
        Err(_) => Err(Error::BadArg),
    }
}

fn image_format(format: ImageFormat) -> NifResult<Atom> {
    match format {
        ImageFormat::PNG => Ok(png()),
        ImageFormat::JPEG => Ok(jpg()),
        ImageFormat::GIF => Ok(gif()),
        _ => Err(Error::Term(Box::new(unsupported_image_format()))),
    }
}

pub fn load(env: Env, _info: Term) -> bool {
    rustler::resource!(Image, env);
    true
}

use image::{DynamicImage, FilterType, GenericImageView, ImageFormat};
use rustler::{
    Atom, Binary, Env, Error, NifResult, NifStruct, NifUnitEnum, OwnedBinary, ResourceArc, Term,
};
use std::io::Write as _;

use crate::atoms::{
    gif, invalid_image, io_error, jpg, ok, out_of_memory, png, unsupported_image_format,
};

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

#[derive(NifUnitEnum)]
pub enum FilterEnum {
    Nearest,
    Triangle,
    CatmullRom,
    Gaussian,
    Lanczos3,
}

impl Into<image::imageops::FilterType> for FilterEnum {
    fn into(self) -> FilterType {
        use FilterEnum::*;

        match self {
            Nearest => FilterType::Nearest,
            Triangle => FilterType::Triangle,
            CatmullRom => FilterType::CatmullRom,
            Gaussian => FilterType::Gaussian,
            Lanczos3 => FilterType::Lanczos3,
        }
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn resize(
    env: Env,
    resource: ResourceArc<Image>,
    width: u32,
    height: u32,
    filter: FilterEnum,
) -> Result<(Atom, Binary, MirageImage), Error> {
    let resized = resource.image.resize_to_fill(width, height, filter.into());
    let mut output = Vec::new();
    let mut binary = OwnedBinary::new(resized.raw_pixels().len())
        .ok_or(Error::Term(Box::new(out_of_memory())))?;

    let _ = resized
        .write_to(&mut output, resource.format)
        .map_err(|_e| Error::Term(Box::new(out_of_memory())))?;

    binary
        .as_mut_slice()
        .write_all(&output)
        .map_err(|_| Error::Term(Box::new(io_error())))?;

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

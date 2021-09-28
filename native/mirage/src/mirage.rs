use image::{imageops::FilterType, DynamicImage, GenericImageView, ImageFormat};
use rustler::{
    Atom, Binary, Env, Error, NifResult, NifStruct, NifUnitEnum, OwnedBinary, ResourceArc, Term,
};
use std::io::Write as _;

use crate::atoms::{
    gif, invalid_image, io_error, jpg, ok, out_of_memory, png, unsupported_image_format,
};

#[derive(NifStruct, Clone)]
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
) -> Result<(Atom, MirageImage), Error> {
    let resized = resource.image.resize(width, height, filter.into());

    let new_image = dyn_to_image(env, resized, resource.format)?;

    Ok((ok(), new_image))
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn resize_to_fill(
    env: Env,
    resource: ResourceArc<Image>,
    width: u32,
    height: u32,
    filter: FilterEnum,
) -> Result<(Atom, MirageImage), Error> {
    let resized = resource.image.resize_to_fill(width, height, filter.into());

    let new_image = dyn_to_image(env, resized, resource.format)?;

    Ok((ok(), new_image))
}

fn dyn_to_image(
    env: Env,
    resized: DynamicImage,
    iformat: ImageFormat,
) -> Result<MirageImage, Error> {
    let mut output = Vec::new();
    let mut binary =
        OwnedBinary::new(resized.pixels().count()).ok_or(Error::Term(Box::new(out_of_memory())))?;

    let _ = resized
        .write_to(&mut output, iformat)
        .map_err(|_e| Error::Term(Box::new(out_of_memory())))?;

    binary
        .as_mut_slice()
        .write_all(&output)
        .map_err(|_| Error::Term(Box::new(io_error())))?;

    let format = image_format(iformat)?;
    let bytes = binary.release(env);
    let byte_size = bytes.as_slice().len();

    Ok(MirageImage {
        byte_size,
        format,
        height: resized.height(),
        width: resized.width(),
        resource: ResourceArc::new(Image {
            image: resized,
            format: iformat,
        }),
    })
}

fn image_format(format: ImageFormat) -> NifResult<Atom> {
    match format {
        ImageFormat::Png => Ok(png()),
        ImageFormat::Jpeg => Ok(jpg()),
        ImageFormat::Gif => Ok(gif()),
        _ => Err(Error::Term(Box::new(unsupported_image_format()))),
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn overlay(
    env: Env,
    bottom: MirageImage,
    top: MirageImage,
    x: u32,
    y: u32,
) -> Result<(Atom, MirageImage), Error> {
    let mut working_image = bottom.resource.image.clone();

    image::imageops::overlay(&mut working_image, &top.resource.image, x, y);

    let new_image = MirageImage {
        byte_size: bottom.byte_size,
        format: bottom.format,
        height: bottom.height,
        width: bottom.width,
        resource: ResourceArc::new(Image {
            image: working_image,
            format: bottom.resource.format,
        }),
    };

    Ok((ok(), new_image))
}

#[derive(NifUnitEnum)]
pub enum Format {
    Png,
    Jpeg,
    Gif,
}

impl Into<ImageFormat> for Format {
    fn into(self) -> ImageFormat {
        use Format::*;

        match self {
            Png => ImageFormat::Png,
            Jpeg => ImageFormat::Jpeg,
            Gif => ImageFormat::Gif,
        }
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn write(env: Env, image: MirageImage, destination: String) -> Result<Atom, Error> {
    image
        .resource
        .image
        .save(destination)
        .map_err(|_e| Error::Term(Box::new(io_error())))?;

    Ok(ok())
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn empty(env: Env, width: u32, height: u32) -> Result<(Atom, MirageImage), Error> {
    let dyn_image = DynamicImage::new_rgba8(width, height);

    let image = dyn_to_image(env, dyn_image, ImageFormat::Png)?;

    Ok((ok(), image))
}

pub fn load(env: Env, _info: Term) -> bool {
    rustler::resource!(Image, env);
    true
}

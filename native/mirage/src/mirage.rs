use std::convert::{TryFrom, TryInto};

use crate::atoms::{invalid_image, io_error, ok, unsupported_image_format};
use image::{imageops::FilterType, DynamicImage, GenericImageView, ImageFormat};
use rustler::{Atom, Binary, Env, Error, NifResult, NifStruct, NifUnitEnum, ResourceArc, Term};

#[derive(NifStruct, Clone)]
#[module = "Mirage.Image"]
pub struct MirageImage {
    byte_size: u32,
    height: u32,
    width: u32,
    resource: ResourceArc<Image>,
}

pub struct Image(DynamicImage);

impl From<DynamicImage> for Image {
    fn from(dynamic_image: DynamicImage) -> Image {
        Image(dynamic_image)
    }
}

impl From<DynamicImage> for MirageImage {
    fn from(dynamic_image: DynamicImage) -> MirageImage {
        MirageImage {
            byte_size: image_size(&dynamic_image),
            height: dynamic_image.height(),
            width: dynamic_image.width(),
            resource: ResourceArc::new(dynamic_image.into()),
        }
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn from_bytes(binary: Binary) -> NifResult<(Atom, Format, MirageImage)> {
    let image = image::load_from_memory(binary.as_slice())
        .map_err(|_e| Error::Term(Box::new(invalid_image())))?;

    let format = image::guess_format(binary.as_slice())
        .map_err(|_e| Error::Term(Box::new(unsupported_image_format())))?;

    let format: Format = format
        .try_into()
        .map_err(|_e| Error::Term(Box::new(unsupported_image_format())))?;

    Ok((ok(), format, image.into()))
}

#[derive(NifUnitEnum)]
pub enum FilterEnum {
    Nearest,
    Triangle,
    CatmullRom,
    Gaussian,
    Lanczos3,
}

impl From<FilterEnum> for image::imageops::FilterType {
    fn from(filter: FilterEnum) -> image::imageops::FilterType {
        use FilterEnum::*;

        match filter {
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
    #[allow(unused_variables)] env: Env,
    resource: ResourceArc<Image>,
    width: u32,
    height: u32,
    filter: FilterEnum,
) -> Result<(Atom, MirageImage), Error> {
    let resized = resource.0.resize(width, height, filter.into());

    let new_image = dyn_to_image(resized);

    Ok((ok(), new_image))
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn resize_to_fill(
    #[allow(unused_variables)] env: Env,
    resource: ResourceArc<Image>,
    width: u32,
    height: u32,
    filter: FilterEnum,
) -> Result<(Atom, MirageImage), Error> {
    let resized = resource.0.resize_to_fill(width, height, filter.into());

    let new_image = dyn_to_image(resized);

    Ok((ok(), new_image))
}

fn dyn_to_image(dynamic_image: DynamicImage) -> MirageImage {
    MirageImage {
        byte_size: image_size(&dynamic_image),
        height: dynamic_image.height(),
        width: dynamic_image.width(),
        resource: ResourceArc::new(dynamic_image.into()),
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn overlay(
    #[allow(unused_variables)] env: Env,
    bottom: MirageImage,
    top: MirageImage,
    x: u32,
    y: u32,
) -> Result<(Atom, MirageImage), Error> {
    let mut working_image = bottom.resource.0.clone();

    image::imageops::overlay(&mut working_image, &top.resource.0, x, y);

    let new_image = dyn_to_image(working_image);

    Ok((ok(), new_image))
}

#[derive(NifUnitEnum)]
pub enum Format {
    Png,
    Jpeg,
    Gif,
    WebP,
    Pnm,
    Tiff,
    Tga,
    Dds,
    Bmp,
    Ico,
    Hdr,
    Farbfeld,
    Avif,
}

impl TryFrom<ImageFormat> for Format {
    type Error = ();

    fn try_from(format: ImageFormat) -> Result<Format, ()> {
        use Format::*;

        Ok(match format {
            ImageFormat::Png => Png,
            ImageFormat::Jpeg => Jpeg,
            ImageFormat::Gif => Gif,
            ImageFormat::WebP => WebP,
            ImageFormat::Pnm => Pnm,
            ImageFormat::Tiff => Tiff,
            ImageFormat::Tga => Tga,
            ImageFormat::Dds => Dds,
            ImageFormat::Bmp => Bmp,
            ImageFormat::Ico => Ico,
            ImageFormat::Hdr => Hdr,
            ImageFormat::Farbfeld => Farbfeld,
            ImageFormat::Avif => Avif,
            _ => return Err(()),
        })
    }
}

impl From<Format> for ImageFormat {
    fn from(format: Format) -> ImageFormat {
        use Format::*;

        match format {
            Png => ImageFormat::Png,
            Jpeg => ImageFormat::Jpeg,
            Gif => ImageFormat::Gif,
            WebP => ImageFormat::WebP,
            Pnm => ImageFormat::Pnm,
            Tiff => ImageFormat::Tiff,
            Tga => ImageFormat::Tga,
            Dds => ImageFormat::Dds,
            Bmp => ImageFormat::Bmp,
            Ico => ImageFormat::Ico,
            Hdr => ImageFormat::Hdr,
            Farbfeld => ImageFormat::Farbfeld,
            Avif => ImageFormat::Avif,
        }
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn write(
    #[allow(unused_variables)] env: Env,
    image: MirageImage,
    destination: String,
) -> Result<Atom, Error> {
    image
        .resource
        .0
        .save(destination)
        .map_err(|_e| Error::Term(Box::new(io_error())))?;

    Ok(ok())
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn empty(
    #[allow(unused_variables)] env: Env,
    width: u32,
    height: u32,
) -> Result<(Atom, MirageImage), Error> {
    let dyn_image = DynamicImage::new_rgba8(width, height);

    Ok((ok(), dyn_image.into()))
}

// Returns the image size in bytes.
fn image_size(image: &DynamicImage) -> u32 {
    image.as_bytes().len() as u32
}

pub fn load(env: Env, _info: Term) -> bool {
    rustler::resource!(Image, env);
    true
}

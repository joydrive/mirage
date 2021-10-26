defmodule MirageTest do
  use ExUnit.Case, async: true

  @test_image_path "./test/support/images/scrogson.jpeg"
  @overlay_image_path "./test/support/images/joydrive.png"
  @overlay_output_image_path "./test/support/images/overlay.png"

  test "resize/3" do
    {:jpeg, image} = Mirage.Image.read!(@test_image_path)

    resized_image = Mirage.resize(image, 200, 200)

    assert image.byte_size > resized_image.byte_size
    assert resized_image.width == 200
    assert resized_image.height == 200
  end

  test "overlay/4" do
    {_, bottom} = Mirage.Image.read!(@test_image_path)
    {_, top} = Mirage.Image.read!(@overlay_image_path)

    bottom
    |> Mirage.overlay(top, 160, 160)
    |> Mirage.Image.write!(@overlay_output_image_path)
  end

  test "resize_to_fill/3" do
    {_, image} = Mirage.Image.read!(@test_image_path)

    image
    |> Mirage.resize_to_fill(1000, 100)
    |> Mirage.Image.write!("./test/support/images/resize_to_fill.png")
  end
end

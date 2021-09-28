defmodule MirageTest do
  use ExUnit.Case

  doctest Mirage

  describe "from_bytes/1" do
    test "loads images and metadata correctly" do
      bytes = File.read!("./test/support/images/scrogson.jpeg")

      byte_size = byte_size(bytes)

      {:ok, image} = Mirage.Image.from_bytes(bytes)

      assert image.byte_size == byte_size
      assert image.format == :jpg
      assert image.width == 460
      assert image.height == 460
      assert is_reference(image.resource)
    end

    test "fails when the provided bytes are not an image" do
      failing_bytes = <<123, 213, 231>>

      {:error, :invalid_image} = Mirage.Image.from_bytes(failing_bytes)
    end

    test "fails when the provided bytes are not an image 2" do
      bytes = File.read!("./test/support/images/scrogson.hdr")

      {:error, :unsupported_image_format} = Mirage.Image.from_bytes(bytes)
    end
  end

  test "resize" do
    bytes = File.read!("./test/support/images/scrogson.jpeg")

    {:ok, image} = Mirage.Image.from_bytes(bytes)

    byte_size = byte_size(bytes)

    {:ok, _new_bytes, image} = Mirage.resize(image, 200, 200)

    assert image.byte_size > byte_size
    assert image.width == 200
    assert image.height == 200
  end

  test "overlay" do
    bottom = File.read!("./test/support/images/scrogson.jpeg")
    top = File.read!("./test/support/images/joydrive.png")

    {:ok, bottom} = Mirage.Image.from_bytes(bottom)
    {:ok, top} = Mirage.Image.from_bytes(top)

    {:ok, new_image} = Mirage.overlay(bottom, top, 160, 160)

    :ok = Mirage.write(new_image, "./test/support/images/overlay.png")
  end
end

defmodule MirageTest do
  use ExUnit.Case, async: true

  doctest Mirage

  describe "from_bytes/1" do
    test "loads images and metadata correctly" do
      bytes = File.read!("./test/support/images/scrogson.jpeg")

      {:ok, :jpeg, image} = Mirage.Image.from_bytes(bytes)

      assert image.byte_size == 634_800
      assert image.width == 460
      assert image.height == 460
      assert is_reference(image.resource)
    end

    test "fails when the provided bytes are not an image" do
      failing_bytes = <<123, 213, 231>>

      {:error, :invalid_image} = Mirage.Image.from_bytes(failing_bytes)
    end
  end

  test "resize" do
    bytes = File.read!("./test/support/images/scrogson.jpeg")

    {:ok, :jpeg, image} = Mirage.Image.from_bytes(bytes)

    resized_image = Mirage.resize(image, 200, 200)

    assert image.byte_size > resized_image.byte_size
    assert resized_image.width == 200
    assert resized_image.height == 200
  end

  test "overlay/4" do
    bottom = File.read!("./test/support/images/scrogson.jpeg")
    top = File.read!("./test/support/images/joydrive.png")

    {:ok, _, bottom} = Mirage.Image.from_bytes(bottom)
    {:ok, _, top} = Mirage.Image.from_bytes(top)

    :ok =
      bottom
      |> Mirage.overlay(top, 160, 160)
      |> Mirage.Image.write("./test/support/images/overlay.png")
  end

  test "resize_to_fill/3" do
    bytes = File.read!("./test/support/images/scrogson.jpeg")

    {:ok, :jpeg, image} = Mirage.Image.from_bytes(bytes)

    :ok =
      image
      |> Mirage.resize(1000, 100)
      |> Mirage.Image.write("./test/support/images/resize_to_fill.png")
  end

  test "empty/2" do
    {:ok, image} = Mirage.Image.empty(100, 100)

    :ok = Mirage.Image.write(image, "./test/support/images/empty.png")
  end
end
